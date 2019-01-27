module Brand
	module V2
		class SessionsAPI < Base
			group do
				resource :sessions do

					desc 'sign in'
					params do
						requires :login, 		type: String
						requires :password, type: String
					end
					post 'sign_in' do
						if @kol = Kol.authenticate_password(params)

							present @kol.user, with: Entities::User
						else
			        return {error: 1, detail: '请输入正确的帐号密码。'}
			      end
					end

					desc "sign up"
					params do 
						requires :type,      type: String, values: %w(email mobile_number)
						requires :login,     type: String
						requires :code,      type: String
						requires :password,  type: String
					end
					post 'sign_up' do
						return {error: 1, detail: '帐号格式不正确。'}        if params[:login].blank?
						return {error: 1, detail: '您已是我们的用户，请登录'} if Kol.authenticate_login(params[:login])
						
						result = 	case params[:type]
											when "mobile_number"
												YunPian::SendRegisterSms.verify_code(params[:login], params[:code])
											when "email"
												$redis.get("valid_#{params[:login]}") == params[:code]
											end
						return {error: 1, detail: '验证码错误'} unless result

						kol = Kol.create("#{params[:type]}": params[:login], password: params[:password])

						user = kol.build_user("#{params[:type]}": params[:login])
						user.mobile_number = user.email if params[:type] == 'email'
						user.save

						present user.reload, with: Entities::User
					end

					desc 'update password'
	        params do
	          requires :login,                      type: String
	          requires :new_password,               type: String
	          requires :new_password_confirmation,  type: String
	          requires :type,                       type: String, desc: 'value in (email or mobile_number)'
	        end
	        post 'update_password' do
	        	kol = Kol.authenticate_login(params[:login])

	          return {error: 1, detail: '该用户不存在'} unless kol

	          if kol.reset_password(params[:new_password], params[:new_password_confirmation])
	            present kol.user, with: Entities::User
	          else
	            error_unprocessable! "密码修改失败，请重试"
	          end
	        end

				end
			end
		end
	end
end