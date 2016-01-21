module API
  module V1
    class Sessions < Grape::API
      resources "users" do
        # 用户注册
        post 'sign_up' do
          required_attributes! [:phone, :code, :password, :role]
          phone_number = PhoneNumber.find_by(phone: params[:phone], :identifying_code => params[:code])
          # error = PhoneNumber.verify_code_and_return_error(params[:phone], params[:code])
          if phone_number.blank?
            error!({error: 1, detail: '错误的验证码'}, 403)
          else
            user = User.new(phone: params[:phone], password: params[:password],
                            password_confirmation: params[:password], role: params[:role],
                            app_platform: params[:app_platform],
                            app_version: params[:app_version]
            )
            if user.save
              if params[:invite_code]
                user.handle_invite_code(params[:invite_code])
              end
              phone_number.destroy
              user.reload
              present :user, user, with: API::V1::Entities::UserEntities::Summary
              present :secret, user, with: API::V1::Entities::UserEntities::Secret
            else
              error!({error: 2, detail: '手机号已被注册'}, 403)
            end
          end

        end

        # 用户登录
        post 'sign_in' do
          required_attributes! [:phone, :password]
          user = User.find_by(phone: params[:phone])
          render error_403!({error: 1, detail: '手机号还没注册'}) if user.blank?
          if user.valid_password?(params[:password])
            user.update_attributes(app_platform: params[:app_platform], app_version: params[:app_version])
            user.reload
            present :user, user, with: API::V1::Entities::UserEntities::Summary
            present :secret, user, with: API::V1::Entities::UserEntities::Secret
          else
            error!({error: 1, detail: '账号或密码错误'}, 403)
          end
        end


      end
    end
  end
end
