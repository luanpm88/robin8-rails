module API
  module V1_3
    class PublicOauth < Grape::API
      resources :public_oauth do
        before do
          authenticate!
        end

        params do
          requires :usrename, type: String
          requires :password, type: String
          optional :code, type: String
        end
        post 'login_with_account' do
          res = Weixin::PublicLogin.login_with_account(params[:username], params[:password], params[:code])
          if res[0] == 'error'
            present :error, 1
            if res[1] == 'account_error'
              present :detail, '账户错误'
            elsif res[1] == 'verify_code'
              present :detail, '账户错误'
            end
          else
            present :error, 0
            if res[0] == 'login_success'
              present :detail, '登陆成功'
            elsif res[1] == 'verify_code'
            end
          end
        end
      end
    end
  end
end
