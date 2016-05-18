module API
  module V1_3
    class PublicLogin < Grape::API
      resources :public_login do
        params do
          requires :username, type: String
          requires :password, type: String
          optional :code, type: String
        end
        post 'login_with_account' do
          res = Weixin::PublicLogin.login(params[:username], params[:password], params[:code])
          if res[0] == 'error'
            present :error, 1
            if res[1] == 'account_error'
              present :detail, '账户错误'
            elsif res[1] == 'verify_code'
              present :detail, '账户错误'
            end
          else
            present :error, 0
            present :status, res[0]
            if res[0] == 'login_success'
              present :detail, '登陆成功'
            elsif res[0] == 'qrcode_success'
              present :login_id,res[1]
              present :qrcode_url,res[2]
            end
          end
        end

        params do
          requires :login_id, type: Integer
        end
        get 'check_status' do
          Weixin::PublicLogin.check_login_status(params[:login_id])
        end
      end
    end
  end
end
