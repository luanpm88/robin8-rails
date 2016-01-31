module API
  module V1
    class Sessions < Grape::API
      resources "kols" do
        # 用户注册
        # post 'sign_up' do
        #   required_attributes! [:mobile_number, :code]
        #   kol = Kol.find_by({:mobile_number => params[:mobile_number]})
        #   return error!({error: 1, detail: '该手机号已经被注册'}, 403)  if kol.present?
        #   code_right = YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
        #   return error!({error: 2, detail: '验证码错误'}, 403)   if !code_right
        #   kol = Kol.create!(mobile_number: params[:mobile_number],  app_platform: params[:app_platform],
        #                   app_version: params[:app_version], device_token: params[:device_token])
        #   if kol.save
        #     kol.reload
        #     present :error, 0
        #     present :kol, kol, with: API::V1::Entities::KolEntities::Summary
        #   else
        #     error!({error: 3, detail: '保存用户出现错误'}, 403)
        #   end
        # end

        # 用户登录
        post 'sign_in' do
          required_attributes! [:mobile_number, :code, :app_platform, :app_version, :device_token]
          code_right = YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
          return error!({error: 2, detail: '验证码错误'}, 403)   if !code_right
          kol = Kol.find_by(mobile_number: params[:mobile_number])
          if kol.present?
            kol.update_attributes(app_platform: params[:app_platform], app_version: params[:app_version], device_token: params[:device_token])
          else
            kol = Kol.create!(mobile_number: params[:mobile_number],  app_platform: params[:app_platform],
                          app_version: params[:app_version], device_token: params[:device_token])
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
          kol =  identity.kol   rescue nil
          if !kol
            ActiveRecord::Base.transaction do
              kol = Kol.create!(app_platform: params[:app_platform], app_version: params[:app_version], device_token: params[:device_token])
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
