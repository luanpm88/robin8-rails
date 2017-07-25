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
          kol = Kol.reg_or_sign_in(params)
          kol.remove_same_device_token(params[:device_token])
          if params[:kol_uuid].present?
            retries = true
            begin
              kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
              if kol_value.present?  && (kol.influence_score.blank? || kol_value.influence_score.to_i > kol.influence_score.to_i  )
                kol.update_influence_result(params[:kol_uuid],kol_value.influence_score, kol_value.updated_at)
                KolInfluenceValueHistory.where(:kol_uuid => kol_value.kol_uuid ).last.update_column(:kol_id, kol.id )   rescue nil
              end
              SyncInfluenceAfterSignUpWorker.perform_async(kol.id, params[:kol_uuid])
            rescue ActiveRecord::StaleObjectError => e
              if retries == true
                retries = false
                kol.reload
                retry
              else
                ::NewRelic::Agent.record_metric('Robin8/Errors/ActiveRecord::StaleObjectError', e)
              end
            end
          end
          present :error, 0
          present :kol, kol, with: API::V1::Entities::KolEntities::Summary
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
            end
            identity.update_column(:unionid, params[:unionid])  if identity == 'wechat' && identity.unionid.blank?
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
        end
      end
    end
  end
end
