module Brand
  module V2
    class CodesAPI < Base
      group do
        resource :codes do

          params do 
            requires :mobile_number, type: String
            requires :login_type, values: %w(sign_up update_password)
          end
          get 'get_phone_code' do
            return {error: 1, detail: '手机号码格式错误'}   unless params[:mobile_number].match(Brand::V2::APIHelpers::MOBILE_NUMBER_REGEXP)
            return {error: 1, detail: '帐号已存在，请登录'} if params[:login_type] == "sign_up" && Kol.find_by_mobile_number(params[:mobile_number])
            
            sms_client = YunPian::SendRegisterSms.new(params[:mobile_number])
            res = sms_client.send_sms  rescue {}
            if res["code"] == 0
              present error: 0, alert: '验证码发送成功'
            else
              return {error: 1, detail: '调用第三方接口错误，请联系客服'}
            end
          end


          params do 
            requires :email, type: String
            requires :login_type, values: %w(sign_up update_password)
          end
          get 'get_email_code' do
            return {error: 1, detail: '邮箱格式错误'}      unless params[:email].match(Brand::V2::APIHelpers::EMAIL_REGEXP)
            return {error: 1, detail: '帐号已存在，请登录'} if params[:login_type] == "sign_up" && Kol.find_by_email(params[:email])
            
            valid_code = SecureRandom.random_number(1000000)
            $redis.setex("valid_#{params[:email]}", 6000, valid_code)
            # NewMemberWorker.perform_async(params[:email], valid_code)

            present error: 0, alert: '验证码已发送您的邮箱，请在10分钟内进行验证，过期请重新获取'
          end

        end
      end
    end
  end
end