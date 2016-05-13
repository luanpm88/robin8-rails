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
          kol = Kol.reg_or_sign_in(params)
          if params[:kol_uuid].present?
            kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
            kol.update_influence_result(params[:kol_uuid],kol_value.influence_score)    if kol_value.present?
            SyncInfluenceAfterSignUpWorker.perform_async(kol.id, params[:kol_uuid])
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
            ActiveRecord::Base.transaction do
              params[:current_sign_in_ip] = request.ip
              kol = Kol.reg_or_sign_in(params)
              #保存头像
              kol.update_attribute(:remote_avatar_url ,  params[:avatar_url])    if params[:avatar_url].present?
              identity = Identity.create_identity_from_app(params.merge(:from_type => 'app', :kol_id => kol.id))   if identity.blank?
            end
            identity.update_column(:unionid, params[:unionid])  if identity == 'wechat' && identity.unionid.blank?
          end
          if params[:kol_uuid].present?
            kol_value = KolInfluenceValue.get_score(params[:kol_uuid])
            kol.update_influence_result(params[:kol_uuid],kol_value.influence_score)     if kol_value.present?
            SyncInfluenceAfterSignUpWorker.perform_async(kol.id, params[:kol_uuid])
          end
          present :error, 0
          present :kol, kol, with: API::V1::Entities::KolEntities::Summary
        end
      end
    end
  end
end
