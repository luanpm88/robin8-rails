module Brand
	module V2
		class SessionsAPI < Base
			group do
				resource :sessions do

					desc 'sign in'
					params do
						requires :login, type: String
						requires :password,    type: String
					end
					post 'sign_in' do
						if @kol = Kol.authenticate_password(params)
							current_user = @kol.user

							present current_user, with: Entities::User
						else
			        error! 'Access Denied', 401
			      end
					end

					desc "register"
					params do 
						requires :type,      type: String  # 'email or mobile_number'
						requires :login,     type: String
						requires :code,      type: String
						requires :password,  type: String
					end
					post 'register' do
						if Kol.authenticate_login(params[:login])
							error! '您已是我们的用户，请登录', 403
						end
						type = params[:type]

						if type == "mobile_number"
							result = YunPian::SendRegisterSms.verify_code(params[:login], params[:code])
						elsif type == "email"
							if $redis.get("valid_#{params[:login]}") == params[:code]
								$redis.del("valid_#{params[:email]}")
								result = true
							else
								result = false
							end
						end

						if result
							kol = Kol.new("#{type}": params[:login], password: params[:password])
							kol.build_user("#{type}": params[:login])
							kol.save
							current_user = kol.user
							present current_user, with: Entities::User
						else
							error! '验证码错误', 403
						end
					end


					desc 'update password'
	        params do
	          requires :login,                      type: String
	          requires :new_password,               type: String
	          requires :new_password_confirmation,  type: String
	          requires :type,                       type: String, desc: 'value in (email or mobile_number)'
	        end
	        post 'update_password' do
	        	if type == "email"
	          	kol = Kol.find_by_email params[:login]
	          elsif type == "mobile_number"
	          	kol = Kol.find_by_mobile_number params[:login]
	          end
	          error_403!(detail: '该用户不存在') unless kol

	          if kol.reset_password params[:new_password], params[:new_password_confirmation]
	          	current_user = kol.user
	            present current_user, with: Entities::User
	          else
	            error_unprocessable! "密码修改失败，请重试"
	          end
	        end



				end
			end
		end
	end
end