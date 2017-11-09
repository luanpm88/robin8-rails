module API
  module V2
    class Phones < Grape::API
      resources :phones do
        get 'get_voice_code' do
          return error_403!({error: 1, detail: '你不能调用该接口'})      if !can_get_code?
          required_attributes! [:mobile_number]
          sms_client = YunPian::SendVoiceSms.new(params[:mobile_number])
          res = sms_client.send_sms  rescue {}
          if res["code"].to_s == '0'
            return {error: 0, detail: '验证码发送成功' }
          else
            error_403!({error: 1, detail: res['msg'] || '调用第三方接口错误，请联系客服'})
          end
        end
      end
    end
  end
end
