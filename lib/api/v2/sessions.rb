module API
  module V2
    class Sessions < Grape::API
      resources :kols do
        # 用户登录
        post 'sign_in' do
          required_attributes! [:kol_uuid, :mobile_number, :code, :app_platform, :app_version, :device_token]
          code_right = YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
          return error!({error: 2, detail: '验证码错误'}, 403)   if !code_right
          kol = Kol.reg_or_sign_in(params)
          SyncInfluenceAfterSignUpWorker.perform_async(kol.id, params[:kol_uuid])     if params[:kol_uuid].present?
          present :error, 0
          present :kol, kol, with: API::V1::Entities::KolEntities::Summary
        end


        #第三方登陆
        params do
          requires :app_platform
          requires :app_version, type: String
          requires :device_token, type: String
          optional :IDFA, type: String
          optional :IMEI, type: String

          requires :provider, type: String, values: ['weibo', 'wechat']
          requires :uid, type: String
          requires :token, type: String
          optional :name, type: String
          optional :url, type: String
          optional :avatar_url, type: String
          optional :desc, type: String
          optional :serial_params, type: String
          optional :followers_count, Integer
          optional :statuses_count, Integer
          optional :registered_at, DateTime
          optional :verified, :boolean
          optional :refresh_token, :string
          optional :unionid, type: String
          optional :kol_uuid, type: String
        end
        post 'oauth_login' do
          identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
          #兼容pc端 wechat
          identity = Identity.find_by(:provider => params[:provider], :unionid => params[:unionid])  if params[:unionid]
          kol = identity.kol   rescue nil
          if !kol
            ActiveRecord::Base.transaction do
              kol = Kol.create!(app_platform: params[:app_platform], app_version: params[:app_version],
                                device_token: params[:device_token], name: params[:name],
                                social_name: params[:name], provider: params[:provider], social_uid: params[:uid],
                                IMEI: params[:IMEI], IDFA: params[:IDFA])
              #保存头像
              kol.update_attribute(remote_avatar_url ,  params[:avatar_url])    if params[:avatar_url].present?
              identity = Identity.create_identity_from_app(params.merge(:from_type => 'app', :kol_id => kol.id))   if identity.blank?
            end
            identity.update_column(:unionid, params[:unionid])  if identity == 'wechat' && identity.unionid.blank?
          end
          SyncInfluenceAfterSignUpWorker.perform_async(kol.id, params[:kol_uuid])     if params[:kol_uuid].present?
          present :error, 0
          present :kol, kol, with: API::V1::Entities::KolEntities::Summary
        end
      end
    end
  end
end
