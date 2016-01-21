module API
  module V1
    class Phones < Grape::API
      resources :phones do
        get "verify" do
          required_attributes! [:mobile_number]
          return error_403!({error: 1, detail: '手机号码已存在!'}) if User.find_by(phone: params[:mobile_number]).present?
          if error
            error_403!({error: 1, detail: error})
          else
            ph.send_identifying_code
            present :phone_number, ph, with: API::V1::Entities::PhoneNumberEntities::Summary
          end
        end

        get 'verify_code' do
          required_attributes! [:mobile_number]
          return error_403!({error: 1, detail: '手机号码不存在!'}) if Kol.find_by(mobile_number: params[:mobile_number]).blank?

        end

        get 'reg_code' do
          required_attributes! [:mobile_number]
          return error_403!({error: 1, detail: '手机号码已经被使用!'}) if Kol.find_by(mobile_number: params[:mobile_number]).present?
          sms_client = YunPian::SendRegisterSms.new(params[:mobile_number])
          res = sms_client.send_sms  rescue {}
          if res['code'] == '0'
            return :json => {error: '0', code: YunPian::SendRegisterSms.get_code(params[:mobile_number]) }.to_json
          else
            error_403!({error: 1, detail: '调用第三方接口错误，请联系客服'})
          end
        end
      end
    end
  end
end
