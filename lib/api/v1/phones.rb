module API
  module V1
    class Phones < Grape::API
      resources :phones do
        get "verify" do
          required_attributes! [:mobile_number, :code]
          return error_403!({error: 1, detail: '验证码与手机号码不匹配!'}) if YunPian::SendRegisterSms.verify_code(params[:mobile_number], params[:code])
          return {error: 0, detail: '验证码发送成功' }
        end

        get 'verification_code' do
          required_attributes! [:mobile_number]
          return error_403!({error: 1, detail: '手机号码不存在!'}) if Kol.find_by(mobile_number: params[:mobile_number]).blank?
          sms_client = YunPian::SendRegisterSms.new(params[:mobile_number])
          res = sms_client.send_sms  rescue {}
          if res['code'] == 0
            return {error: 0, detail: '验证码发送成功' }
          else
            error_403!({error: 1, detail: '调用第三方接口错误，请联系客服'})
          end
        end

        get 'reg_code' do
          required_attributes! [:mobile_number]
          return error_403!({error: 1, detail: '手机号码已经被使用!'}) if Kol.find_by(mobile_number: params[:mobile_number]).present?
          sms_client = YunPian::SendRegisterSms.new(params[:mobile_number])
          res = sms_client.send_sms  rescue {}
          if res["code"] == 0
            return {error: 0, detail: '验证码发送成功' }
          else
            error_403!({error: 1, detail: '调用第三方接口错误，请联系客服'})
          end
        end
      end
    end
  end
end
