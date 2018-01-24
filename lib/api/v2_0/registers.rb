# coding: utf-8
module API
  module V2_0
    class Registers < Grape::API
      resources :registers do

        params do
          requires :email, type: String
        end
        get 'email_valid' do
          email = params[:email]
          error_403!({detail: '邮箱格式错误' }) unless format_email(email)
          error_403!({detail: '邮箱已被注册' }) if Kol.find_by(email: email)

          valid_code = $redis.get("reg_#{email}")

          unless valid_code
            $redis.set("reg_#{email}", rand(8999)+1000)
            $redis.expire("reg_#{email}", 300)
          end

          res = UserMailer.new_member(email, valid_code).deliver_now

          if res.errors.empty?
            present error: 0, alert: '验证码已发送您的邮箱，请在5分钟内进行验证，过期请重新获取'
          else
            error_403!({detail: res.errors.join('.') })
          end
        end

        params do
          requires :reg_type,   type: String, desc: "mobile(default) | email"
          requires :login,      type: String
          requires :password,   type: String
          requires :valid_code, type: String
        end
        post '/' do
          error_403!({detail: '参数错误' }) unless [nil, 'mobile', 'email'].include?(params[:reg_type])

          if params[:reg_type] == 'email'
            error_403!({detail: '邮箱验证错误' }) unless $redis.get("reg_#{params[:login]}") == params[:valid_code]

            _kol_hash = {email: params[:login], password: params[:password]}
          else
            _kol_hash = {mobile_number: params[:login], password: params[:password]}
          end

          kol = Kol.new(_kol_hash)

          if kol.save!
            present error: 0, alert: '您已注册成功，请登录'
          else
            error_403!({detail: kol.errors.join('.') })
          end
        end
        
      end
    end
  end
end
