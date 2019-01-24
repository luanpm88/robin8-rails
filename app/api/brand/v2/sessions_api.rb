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
				end
			end
		end
	end
end