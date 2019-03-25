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
			        return {error: 1, detail: I18n.t('brand_api.errors.messages.account_password_error')}
			      end
					end

					desc "sign up"
					params do 
						requires :type,      type: String
						requires :login,     type: String
						requires :code,      type: String
						requires :password,  type: String
					end
					post 'sign_up' do
						return {error: 1, detail: I18n.t('brand_api.errors.messages.account_format_error')}        if params[:login].blank?
						return {error: 1, detail: I18n.t('brand_api.errors.messages.user_have_exist')} if Kol.authenticate_login(params[:login])
						
						result = 	case params[:type]
											when "mobile_number"
												YunPian::SendRegisterSms.verify_code(params[:login], params[:code])
											when "email"
												$redis.get("valid_#{params[:login]}") == params[:code]
											end
						return {error: 1, detail: I18n.t('brand_api.errors.messages.code_error')} unless result

						kol = Kol.create("#{params[:type]}": params[:login], password: params[:password])

						user = kol.build_user("#{params[:type]}": params[:login])
						user.mobile_number = user.email if params[:type] == 'email'
						user.save

						present user.reload, with: Entities::User
					end

					desc 'update password'
	        params do
	          requires :login,                      type: String
	          requires :code,                       type: String 
	          requires :new_password,               type: String
	          requires :new_password_confirmation,  type: String
	        end
	        post 'update_password' do
	        	kol = Kol.authenticate_login(params[:login])

	          return {error: 1, detail: I18n.t('brand_api.errors.messages.forget_not_found')} unless kol

	          if params[:login].match(Brand::V2::APIHelpers::MOBILE_NUMBER_REGEXP)
	          	result = YunPian::SendRegisterSms.verify_code(params[:login], params[:code])
	          elsif params[:login].match(Brand::V2::APIHelpers::EMAIL_REGEXP)
	          	result = $redis.get("valid_#{params[:login]}") == params[:code]
	          else
	          	result = false
	          end
	          
	          return {error: 1, detail: I18n.t('brand_api.errors.messages.code_error')} unless result 

	          if kol.reset_password(params[:new_password], params[:new_password_confirmation])
	            present kol.user, with: Entities::User
	          else
	          	return {error: 1, detail: I18n.t('brand_api.errors.messages.update_failed')}
	          end
	        end


				end
			end
		end
	end
end