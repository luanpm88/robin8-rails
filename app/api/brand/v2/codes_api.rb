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
            return {error: 1, detail: I18n.t('brand_api.errors.messages.mobile_number_error')}   unless params[:mobile_number].match(Brand::V2::APIHelpers::MOBILE_NUMBER_REGEXP)
            return {error: 1, detail: I18n.t('brand_api.errors.messages.user_have_exist')} if params[:login_type] == "sign_up" && Kol.find_by_mobile_number(params[:mobile_number])
            
            sms_client = YunPian::SendRegisterSms.new(params[:mobile_number])
            res = sms_client.send_sms  rescue {}
            if res["code"] == 0
              present error: 0, alert: I18n.t('brand_api.success.messages.code_succeed')
            else
              return {error: 1, detail: I18n.t('brand_api.errors.messages.third_party_error')}
            end
          end


          params do 
            requires :email, type: String
            requires :login_type, values: %w(sign_up update_password)
          end
          get 'get_email_code' do
            return {error: 1, detail: I18n.t('brand_api.errors.messages.email_format_error')}      unless params[:email].match(Brand::V2::APIHelpers::EMAIL_REGEXP)
            return {error: 1, detail: I18n.t('brand_api.errors.messages.user_have_exist')} if params[:login_type] == "sign_up" && Kol.find_by_email(params[:email])
            
            valid_code = SecureRandom.random_number(1000000)
            $redis.setex("valid_#{params[:email]}", 6000, valid_code)
            NewMemberWorker.perform_async(params[:email], valid_code)

            present error: 0, alert: I18n.t('brand_api.errors.messages.code_succeed_message')
          end

        end
      end
    end
  end
end