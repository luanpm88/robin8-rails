module API
  module V1
    class Sessions < Grape::API
      resources "kols" do
        # 用户登录
        post 'sign_in' do
          required_attributes! [:mobile_number, :code, :app_platform, :app_version, :device_token]
          code_right = YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
          return error!({error: 2, detail: '验证码错误'}, 403)   if !code_right
          kol = Kol.find_by(mobile_number: params[:mobile_number])
          if kol.present?
            kol.update_attributes(app_platform: params[:app_platform], app_version: params[:app_version],
                                  device_token: params[:device_token], IMEI: params[:IMEI], IDFA: params[:IDFA])
          else
            kol = Kol.create!(mobile_number: params[:mobile_number],  app_platform: params[:app_platform],
                          app_version: params[:app_version], device_token: params[:device_token],
                          IMEI: params[:IMEI], IDFA: params[:IDFA], name: params[:mobile_number])
          end
          kol.reload
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
          optional :serial_params, type: JSON
        end
        post 'oauth_login' do
          identity = Identity.find_by(:provider => params[:provider], :uid => params[:uid])
          kol = identity.kol   rescue nil
          if !kol
            ActiveRecord::Base.transaction do
              kol = Kol.create!(app_platform: params[:app_platform], app_version: params[:app_version],
                                device_token: params[:device_token], name: params[:name],
                                social_name: params[:name], provider: params[:provider], social_uid: params[:uid],
                                IMEI: params[:IMEI], IDFA: params[:IDFA])
              #保存头像
              if params[:avatar_url].present?
                kol.remote_avatar_url =  params[:avatar_url]
                kol.save
              end
              if identity.blank?
                attrs = attributes_for_keys [:provider, :uid, :token, :name, :url, :avatar_url, :desc, :serial_params]
                identity = Identity.new
                identity.attributes = attrs
                identity.kol_id = kol.id
                identity.save
              end
            end
          end
          present :error, 0
          present :kol, kol, with: API::V1::Entities::KolEntities::Summary
        end
      end
    end
  end
end
