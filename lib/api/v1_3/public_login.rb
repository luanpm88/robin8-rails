module API
  module V1_3
    class PublicLogin < Grape::API
      before do
        authenticate!
      end

      resources :public_login do
        params do
          optional :username, type: String
          optional :password, type: String
          optional :imgcode, type: String
          optional :cookies, type: String
          optional :identity_id, type: Integer
          exactly_one_of :username, :identity_id
        end
        post 'login_with_account' do
          if params[:identity_id]
            identity = AnalysisIdentity.find params[:identity_id]    rescue nil
            if identity.blank?
              present :error, 0
              present :detail, '账号没有找到'
            else
              params[:username] = identity.name
              params[:password] = PasswordHandle.decode_pwd(identity.password_encrypted)
            end
          end
          res = ::IdentityAnalysis::PublicLogin.login(current_kol.id, params[:username], params[:password], params[:imgcode], params[:cookies])
          if res[0] == 'error'
            present :error, 1
            present :login_status, res[1]
            if res[1] == 'account_wrong'
              present :detail, '账户错误'
            elsif res[1] == 'verify_code'
              present :detail, '验证码错误'
              present :imgcode_url, IdentityAnalysis::PublicLogin.verify_code_url(params[:username])
            end
          else
            present :error, 0
            present :login_status, res[0]
            if res[0] == 'login_success'
              present :detail, '登陆成功'
              present :login_id,res[1]
            elsif res[0] == 'qrcode_success'
              present :detail, '请扫描二维码'
              present :login_id,res[1]
              present :qrcode_url,res[2]
            end
          end
        end


        params do
          requires :login_id, type: Integer
        end
        get 'check_status' do
          res = ::IdentityAnalysis::PublicLogin.check_login_status(params[:login_id])
          if res == '405'
            status_content = '登陆成功'
          elsif res == 401
            status_content = '等待扫码中'
          elsif res == 402
            status_content = '二维码已经过期'
          elsif res == 403
            status_content = '取消扫码'
          elsif res == 404
            status_content = '确认中'
          elsif res == 406
            status_content = '初始化中'
          elsif res == 407
            status_content = '请求中'
          elsif res == 500
            status_content = '出错了'
          end
          present :error, 0
          present :status, res
          present :status_content, status_content
        end

      end
    end
  end
end
