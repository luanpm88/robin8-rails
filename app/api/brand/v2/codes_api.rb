module Brand
  module V2
    class CodesAPI < Base
      group do
        resource :codes do

          params do 
            requires :mobile_number, type: String 
          end
          get 'get_phone_code' do
            error_403!(detail: '手机号码格式错误') unless params[:mobile_number].match(Brand::V2::APIHelpers::MOBILE_NUMBER_REGEXP)
            
            sms_client = YunPian::SendRegisterSms.new(params[:mobile_number])
            res = sms_client.send_sms  rescue {}
            if res["code"] == 0
              present error: 0, alert: '验证码发送成功'
            else
              error_403!({error: 1, detail: '调用第三方接口错误，请联系客服'})
            end
          end


          params do 
            requires :email,      type: String 
          end
          get 'get_email_code' do
            error_403!(detail: '邮箱格式错误') unless params[:email].match(Brand::V2::APIHelpers::EMAIL_REGEXP)
            
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