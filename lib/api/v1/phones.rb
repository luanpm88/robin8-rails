module API
  module V1
    class Phones < Grape::API
      resources :phones do
        post "verify_code" do
          required_attributes! [:mobile_number, :code]
          return error_403!({error: 1, detail: 'The verification code does not match the mobile number!'}) if !YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
          return {error: 0, detail: 'Verification passed!' }
        end

        get 'verification_code' do
          required_attributes! [:mobile_number]
          return error_403!({error: 1, detail: 'Mobile number does not exist!'}) if Kol.find_by(mobile_number: params[:mobile_number]).blank?
          sms_client = YunPian::SendInternationalSms.new(params[:mobile_number])
          res = sms_client.send_sms  rescue {}
          if res['code'] == 0
            return {error: 0, detail: 'The verification code was sent successfully.' }
          else
            error_403!({error: 1, detail: 'Call third-party interface error, please contact customer service'})
          end
        end

        get 'get_code' do
          return error_403!({error: 1, detail: 'You can\'t call this interface'})      if !can_get_code?
          required_attributes! [:mobile_number]
          sms_client = YunPian::SendInternationalSms.new(params[:mobile_number])
          res = sms_client.send_sms  rescue {}
          if res["code"] == 0
            return {error: 0, detail: 'The verification code was sent successfully' }
          else
            error_403!({error: 1, detail: 'Call third-party interface error, please contact customer service'})
          end
        end

        post 'get_code' do
          # return error_403!({error: 1, detail: '你不能调用该接口'})      if !can_get_code?
          required_attributes! [:mobile_number]
          
          phone_number = params[:mobile_number]
          if phone_number[0] == '0'
            phone_number = '+84' + phone_number[1..-1]
          elsif phone_number[0] != '+'
            phone_number = '+' + phone_number
          end
          
          sms_client = YunPian::SendInternationalSms.new(phone_number)
          res = sms_client.send_sms  rescue {}
          if res["code"] == 0
            return {error: 0, detail: 'The verification code was sent successfully' }
          else
            error_403!({error: 1, detail: 'Call third-party interface error, please contact customer service'})
          end
        end

        post 'verification_code' do
          # required_attributes! [:mobile_number]
          return error_403!({error: 1, detail: 'Mobile number does not exist!'}) if Kol.find_by(mobile_number: params[:mobile_number]).blank?
          
          phone_number = params[:mobile_number]
          if phone_number[0] == '0'
            phone_number = '+84' + phone_number[1..-1]
          elsif phone_number[0] != '+'
            phone_number = '+' + phone_number
          end
          
          sms_client = YunPian::SendInternationalSms.new(phone_number)
          res = sms_client.send_sms  rescue {}
          if res['code'] == 0
            return {error: 0, detail: 'The verification code was sent successfully.' }
          else
            error_403!({error: 1, detail: 'Call third-party interface error, please contact customer service'})
          end
        end
      end
    end
  end
end
