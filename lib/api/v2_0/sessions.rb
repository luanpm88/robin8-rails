# encoding: utf-8
module API
  module V2_0
    class Sessions < Grape::API
      resources :sessions do

        desc 'v2_0 login'
      	params do
      		requires :login, type: String
      		requires :password, type: String
      	end
      	post '/' do
          error_403!(detail: '该邮箱未注册') unless Kol.find_by_email(params[:login])
          
      		if kol = Kol.authenticate_password(params)
      			present :error, 0
          	present :kol, kol, with: API::V1::Entities::KolEntities::Summary
      		else
      			error_403!(detail: '请输入正确的邮箱和密码')
      		end 
      	end

        desc 'update password'
        params do
          requires :email,                      type: String
          requires :new_password,               type: String
          requires :new_password_confirmation,  type: String
          requires :vtoken,                     type: String, desc: 'vtoken is generated by email valid successfully'
        end
        post 'update_password' do
          error_403!(detail: '出错啦，请联系小萝缤') unless $redis.get("vtoken_#{params[:email]}") == params[:vtoken]

          kol = Kol.find_by_email params[:email]
          error_403!(detail: '该用户不存在') unless kol

          if kol.reset_password params[:new_password], params[:new_password_confirmation]
            present :error, 0
            present :kol, kol, with: API::V1::Entities::KolEntities::Summary
          else
            error_unprocessable! "密码修改失败，请重试"
          end
        end

      end
    end
  end
end