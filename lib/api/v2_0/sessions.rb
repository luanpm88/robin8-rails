# coding: utf-8
module API
  module V2_0
    class Sessions < Grape::API
      resources :sessions do

      	params do
      		requires :login, type: String
      		requires :password, type: String
      	end
      	post '/' do
      		if kol = Kol.authenticate_password(params)
      			present :error, 0
          	present :kol, kol, with: API::V1::Entities::KolEntities::Summary
      		else
      			error_403!(detail: '请输入正确的邮箱和密码')
      		end 
      	end

      end
    end
  end
end