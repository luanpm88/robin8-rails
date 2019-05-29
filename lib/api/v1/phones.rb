module API
  module V1
    class Phones < Grape::API
      resources :phones do
        post "verify_code" do
          required_attributes! [:mobile_number, :code]
          return error_403!({error: 1, detail: '验证码与手机号码不匹配!'}) if !YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
          return {error: 0, detail: '验证通过' }
        end

        get 'verification_code' do
          required_attributes! [:mobile_number]
          return error_403!({error: 1, detail: '手机号码不存在!'}) if Kol.find_by(mobile_number: params[:mobile_number]).blank?
          sms_client = YunPian::SendInternationalSms.new(params[:mobile_number])
          res = sms_client.send_sms  rescue {}
          if res['code'] == 0
            return {error: 0, detail: '验证码发送成功' }
          else
            error_403!({error: 1, detail: '调用第三方接口错误，请联系客服'})
          end
        end

        get 'get_code' do
          return error_403!({error: 1, detail: '你不能调用该接口'})      if !can_get_code?
          required_attributes! [:mobile_number]
          sms_client = YunPian::SendInternationalSms.new(params[:mobile_number])
          res = sms_client.send_sms  rescue {}
          if res["code"] == 0
            return {error: 0, detail: '验证码发送成功' }
          else
            error_403!({error: 1, detail: '调用第三方接口错误，请联系客服'})
          end
        end

        post 'get_code' do
          # return error_403!({error: 1, detail: '你不能调用该接口'})      if !can_get_code?
          required_attributes! [:mobile_number]
          sms_client = YunPian::SendInternationalSms.new(params[:mobile_number])
          res = sms_client.send_sms  rescue {}
          if res["code"] == 0
            return {error: 0, detail: '验证码发送成功' }
          else
            error_403!({error: 1, detail: '调用第三方接口错误，请联系客服'})
          end
        end

        post 'verification_code' do
          # required_attributes! [:mobile_number]
          return error_403!({error: 1, detail: '手机号码不存在!'}) if Kol.find_by(mobile_number: params[:mobile_number]).blank?
          sms_client = YunPian::SendInternationalSms.new(params[:mobile_number])
          res = sms_client.send_sms  rescue {}
          if res['code'] == 0
            return {error: 0, detail: '验证码发送成功' }
          else
            error_403!({error: 1, detail: '调用第三方接口错误，请联系客服'})
          end
        end
      end
    end
  end
end
