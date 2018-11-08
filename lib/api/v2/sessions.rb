module API
  module V2
    class Sessions < Grape::API
      resources :kols do
        # 用户登录
        post 'sign_in' do
          required_attributes! [:mobile_number, :code, :app_platform, :app_version, :device_token]
          code_right = YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
          return error!({error: 2, detail: '验证码错误'}, 403)   if !code_right
          params[:current_sign_in_ip] = request.ip
          kol_exist = Kol.find_by(mobile_number: params[:mobile_number]).present?
          return error!({error: 1, detail: '该设备已绑定3个账号!'}, 403)   if !kol_exist && Kol.device_bind_over_3(params[:IMEI], params[:IDFA])
          if params[:invite_code].present?
            result = check_invite_code(params[:invite_code] , kol_exist) 
            return error!({error: 2, detail: result}, 403)  unless result == true
          end

          kol = Kol.reg_or_sign_in(params)

          kol.invite_code_dispose(params[:invite_code]) if params[:invite_code].present?
          kol.remove_same_device_token(params[:device_token])
          # if params[:kol_uuid].present?
          #   retries = true
          #   begin
          #     kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
          #     if kol_value.present?  && (kol.influence_score.blank? || kol_value.influence_score.to_i > kol.influence_score.to_i  )
          #       kol.update_influence_result(params[:kol_uuid],kol_value.influence_score, kol_value.updated_at)
          #       KolInfluenceValueHistory.where(:kol_uuid => kol_value.kol_uuid ).last.update_column(:kol_id, kol.id )   rescue nil
          #     end
          #     SyncInfluenceAfterSignUpWorker.perform_async(kol.id, params[:kol_uuid])
          #   rescue ActiveRecord::StaleObjectError => e
          #     if retries == true
          #       retries = false
          #       kol.reload
          #       retry
          #     else
          #       ::NewRelic::Agent.record_metric('Robin8/Errors/ActiveRecord::StaleObjectError', e)
          #     end
          #   end
          # end

          alert = nil
          unless kol_exist
            # 注册奖励
            if kol.strategy[:register_bounty] > 0
              kol.income(kol.strategy[:register_bounty], 'register_bounty') 
              alert = "由于您是 #{kol.strategy[:tag]} 用户，注册赠送奖励#{kol.strategy[:register_bounty]}元"
            end
            # kol.admin奖励
            kol.admin.income(kol.strategy[:invite_bounty_for_admin], 'invite_bounty_for_admin', kol) if kol.admin && kol.strategy[:invite_bounty_for_admin] > 0
          
            # HSBC 注册奖励
            if params[:invite_code] == '666888'
              alert = "恭喜您获得NIIT免费课程门票！涵盖：\n价值1000元\n超过120门课程\n1个月免费学习时间\n领取方法稍后短信通知"
              YunPian::Hsbc.new(params[:mobile_number]).send_sms
            end
          end

          present :error, 0
          present :kol, kol, with: API::V1::Entities::KolEntities::Summary
          present :kol_identities, kol.identities, with: API::V1::Entities::IdentityEntities::Summary
          present :is_new_member, !kol_exist
          present :alert, alert
        end


        #第三方登陆
        params do
          requires :app_platform, type: String
          requires :app_version, type: String
          requires :device_token, type: String
          optional :os_version, type: String
          optional :device_model, type: String
          optional :city_name, type: String
          optional :IDFA, type: String
          optional :IMEI, type: String

          requires :provider, type: String, values: ['weibo', 'wechat', 'qq']
          requires :uid, type: String
          requires :token, type: String
          optional :name, type: String
          optional :url, type: String
          optional :avatar_url, type: String
          optional :desc, type: String
          optional :serial_params, type: String
          optional :followers_count, type: Integer
          optional :statuses_count, type: Integer
          optional :registered_at, type: DateTime
          optional :verified, type: Boolean
          optional :refresh_token, type: String
          optional :unionid, type: String

          optional :province, type: String
          optional :city, type: String
          optional :gender, type: String
          optional :is_vip, type: Boolean
          optional :is_yellow_vip, type: Boolean

          optional :kol_uuid, type: String
          optional :utm_source, type: String
        end
        post 'oauth_login' do
          identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
          #兼容pc端 wechat
          identity = Identity.find_by(:provider => params[:provider], :unionid => params[:unionid])  if identity.blank? && params[:unionid]
          kol = identity.kol   rescue nil
          alert = nil
          if !kol
            return error!({error: 1, detail: '该设备已绑定3个账号!'}, 403)   if Kol.device_bind_over_3(params[:IMEI], params[:IDFA])

            unless Identity.is_valid_identity?(params[:provider], params[:token], params[:uid])
              Rails.logger.info "---- oauth_login --- invalid login data: #{params}"
              return error!({error: 1, detail: 'Invalid oauth login data'}, 403)
            end
            
            ActiveRecord::Base.transaction do
              params[:current_sign_in_ip] = request.ip
              kol = Kol.reg_or_sign_in(params)
              identity = Identity.create_identity_from_app(params.merge(:from_type => 'app', :kol_id => kol.id))   if identity.blank?
              social = update_social(params.merge(:from_type => 'app', :kol_id => kol.id))
            end
            identity.update_column(:unionid, params[:unionid])  if identity == 'wechat' && identity.unionid.blank?

            # 注册奖励
            if kol.strategy[:register_bounty] > 0
              kol.income(kol.strategy[:register_bounty], 'register_bounty') 
              alert = "由于您是 #{kol.strategy[:tag]} 用户，注册赠送奖励#{kol.strategy[:register_bounty]}元"
            end
            # kol.admin奖励
            kol.admin.income(kol.strategy[:invite_bounty_for_admin], 'invite_bounty_for_admin', kol) if kol.admin && kol.strategy[:invite_bounty_for_admin] > 0
          else
            kol = Kol.reg_or_sign_in(params, kol)
          end
          if params[:kol_uuid].present?
            kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
            if kol_value.present?  && (kol.influence_score.blank? || kol_value.influence_score.to_i > kol.influence_score.to_i  )
              kol.update_influence_result(params[:kol_uuid],kol_value.influence_score, kol_value.updated_at)
              KolInfluenceValueHistory.where(:kol_uuid => kol_value.kol_uuid ).last.update_column(:kol_id, kol.id )   rescue nil
            end
            SyncInfluenceAfterSignUpWorker.perform_async(kol.id, params[:kol_uuid])
          end
          kol.remove_same_device_token(params[:device_token])
          present :error, 0
          present :kol, kol, with: API::V1::Entities::KolEntities::Summary
          present :alert, alert
        end
      end
    end
  end
end
