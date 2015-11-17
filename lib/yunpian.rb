module Yunpian
  class SmsClient
    def initialize(phone_number,
                   api_key = Rails.application.secrets.yunpian[:api_key],
                   company_sign = Rails.application.secrets.yunpian[:company_sign])
      @phone_number = phone_number
      @api_key = api_key
      @company_sign = company_sign
    end

    def send_sms
      return if @phone_number.blank?

      code = security_code
      write_cache_for @phone_number, code

      return if Rails.env.development? || Rails.env.test?

      ChinaSMS.use :yunpian, password: @api_key
      tpl_params = {code: code, company: @company_sign}
      begin
        res = ChinaSMS.to @phone_number, tpl_params, tpl_id: 1
      rescue Exception => ex
        Rails.logger.error ex
        return nil
      end

      if res["code"] == 0
        Rails.logger.info "Send sms to #{@phone_number} successfully when sign up"
      else
        Rails.logger.info "Failed to send sms to #{@phone_number}, the return code is #{res["code"]}, please look up https://www.yunpian.com/api/recode.html"
      end

      return res

    end

    def write_cache_for phone_number, code
      Rails.cache.write(phone_number, code, expires_in: 3.minute)
    end

    def security_code
      code = Rails.cache.fetch(@phone_number) || generate_security_code
    end

    def generate_security_code
      (Rails.env.development? || Rails.env.test?) ? '1234' : (1..9).to_a.sample(4).join
    end
  end
end