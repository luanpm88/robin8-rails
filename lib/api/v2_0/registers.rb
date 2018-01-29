module API
  module V2_0
    class Registers < Grape::API
      resources :registers do

        desc 'get valid code by your email.'
        params do
          requires :email, type: String, regexp: API::ApiHelpers::EMAIL_REGEXP
        end
        get 'valid_code' do
          email = params[:email]

          error_403!(detail: '邮箱已被注册') if Kol.find_by(email: email)

          valid_code = $redis.get("reg_#{email}")

          unless valid_code
            valid_code = SecureRandom.random_number(1000000)
            $redis.setex("reg_#{email}", 3000, valid_code)
          end

          NewMemberWorker.perform_async(email, valid_code)

          present error: 0, alert: '验证码已发送您的邮箱，请在5分钟内进行验证，过期请重新获取'
        end

        desc 'email valid code'
        params do
          requires :email,      type: String
          requires :valid_code, type: String
        end
        post 'valid_email' do
          if $redis.get("reg_#{params[:email]}") == params[:valid_code]
            vtoken = $redis.setex("valid_#{email}", SecureRandom.base64, 3000)
            
            present error: 0, alert: '邮箱验证成功',vtoken: vtoken
          else
            error_403!(detail: '邮箱验证错误') 
          end
        end

        desc 'create new kol'
        params do
          requires :name,           type: String
          requires :email,          type: String
          requires :password,       type: String
          requires :vtoken,         type: String, desc: 'vtoken is generated by email valid successfully'
          optional :mobile_number,  type: String
        end
        post '/' do
          error_403!(detail: '参数错误') unless $redis.get("valid_#{params[:email]}") == params[:vtoken]

          _kol_hash = {}

          %i(name email password mobile_number).collect{|ele| _kol_hash[ele] = params[ele]}

          kol = Kol.new(_kol_hash)

          if kol.save!
            present :error, 0
            present :kol, kol, with: API::V1::Entities::KolEntities::Summary
          else
            error_403!(detail: kol.errors.join('.'))
          end
        end
        
      end
    end
  end
end
