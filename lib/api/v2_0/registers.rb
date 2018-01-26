# coding: utf-8
module API
  module V2_0
    class Registers < Grape::API
      resources :registers do

        desc 'get valid code by your email.'
        params do
          requires :email, type: String
        end
        get 'valid_code' do
          email = params[:email]
          error_403!(detail: '邮箱格式错误') unless format_email(email)
          error_403!(detail: '邮箱已被注册') if Kol.find_by(email: email)

          valid_code = $redis.get("reg_#{email}")

          $redis.setex("reg_#{email}", rand(8999)+1000, 3000) unless valid_code
          
          valid_code = $redis.get("reg_#{email}")

          # res = UserMailer.new_member(email, valid_code).deliver_now

          # if res.errors.empty?
          if true
            present error: 0, valid_code: valid_code, alert: '验证码已发送您的邮箱，请在5分钟内进行验证，过期请重新获取'
          else
            error_403!(detail: res.errors.join('.'))
          end
        end

        desc 'email valid code'
        params do
          requires :email,      type: String
          requires :valid_code, type: String
        end
        post 'valid_email' do
          if $redis.get("reg_#{params[:email]}") == params[:valid_code]
            present error: 0, alert: '邮箱验证成功'
          else
            error_403!(detail: '邮箱验证错误')
          end
        end

        desc 'create new kol'
        params do
          requires :name,       type: String
          requires :email,      type: String
          requires :password,   type: String
        end
        post '/' do
          _kol_hash = {}

          %i(name email password mobile_number).each do |ele|
            _kol_hash[ele] = params[ele]
          end

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
