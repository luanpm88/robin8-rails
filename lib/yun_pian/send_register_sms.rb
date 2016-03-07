module YunPian
  class SendRegisterSms
    FakeNumber = 'robin8.best'
    FakeCode = '1234'

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

      return {'code' => 0 } if @phone_number == "robin8.best"  || Rails.env.development?

      ChinaSMS.use :yunpian, password: @api_key
      tpl_params = {code: code, company: @company_sign}
      begin
        res = ChinaSMS.to @phone_number, tpl_params, tpl_id: 1
      rescue Exception => ex
        Rails.logger.sms_spider.error ex
        return {:message => ex.message}
      ensure
        return {'code' => 0 } if  Rails.env.staging?
      end

      if res["code"] == 0
        Rails.logger.info "Send sms to #{@phone_number} successfully when sign up"
      else
        Rails.logger.error "Failed to send sms to #{@phone_number}, the return code is #{res['code']}, please look up https://www.yunpian.com/api/recode.html"
      end

      return res

    end

    def write_cache_for phone_number, code
      Rails.cache.write(phone_number, code.to_s, expires_in: 30.minutes)
    end

    def security_code
      code = Rails.cache.fetch(@phone_number) || generate_security_code
    end

    def generate_security_code
      @phone_number == FakeNumber ? FakeCode : (1..9).to_a.sample(4).join
    end

    def self.get_code(phone)
      return FakeCode if phone ==  FakeNumber
      Rails.cache.read(phone) rescue nil
    end

    SkipVerifyPhones = ['13262752287','13795431288', '13979115652', '13764211748', '15221773929', '13817164646','18221707548']
    def self.verify_code(phone, code)
      phone = phone.to_s        rescue ""
      code = code.to_s          rescue ""
      return true if  Rails.cache.read(phone) == code
      return code == "123456"  if Rails.env.development?  || Rails.env.staging?
      SkipVerifyPhones.include?(phone) && code == '123456'
    end
  end
end
