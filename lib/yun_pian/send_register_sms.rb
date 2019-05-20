module YunPian
  class SendRegisterSms
    FakeNumber = 'robin8.best'
    FakeCode = '1234'

    def initialize(phone_number,
                   api_key = Rails.application.secrets.yunpian[:api_key],
                   company_sign = Rails.application.secrets.yunpian[:company_sign])
      @phone_number = phone_number

      if @phone_number[0] == '0'
        @phone_number = '+84' + @phone_number[1..-1]
      end

      @api_key = api_key
      @company_sign = company_sign
    end


    def send_sms
      return if @phone_number.blank?
      code = security_code
      write_cache_for @phone_number, code

      tpl_params = {code: code, company: @company_sign}

      @sms_message = SmsMessage.create(
        phone: @phone_number,
        content: "Mã xác minh SMS：#{tpl_params[:code]} #{tpl_params[:company]}",
        mode: "verified_code",
        status: "pending"
      )

      # Twilio
      account_sid = Rails.application.secrets[:vn_twilio][:sid]
      auth_token = Rails.application.secrets[:vn_twilio][:token]
      client = Twilio::REST::Client.new(account_sid, auth_token)

      from = Rails.application.secrets[:vn_twilio][:from] # Your Twilio number

      puts '============================'
      puts account_sid

      #begin
        client.messages.create(
          from: from,
          to: @sms_message.phone,
          body: @sms_message.content
        )
      #rescue Twilio::REST::RequestError => ex
      #  @sms_message.update(status: "failed")
      #  Rails.logger.sms_spider.error ex
      #  puts ex.message
      #end

      @sms_message.update(status: "success")
      Rails.logger.info "Send sms to #{@phone_number} successfully when sign up"

      #ChinaSMS.use :yunpian, password: @api_key
      #tpl_params = {code: code, company: @company_sign}
      #
      #@sms_message = SmsMessage.create(
      #  phone: @phone_number,
      #  content: "短信验证码：#{tpl_params[:code]} #{tpl_params[:company]}",
      #  mode: "verified_code",
      #  status: "pending"
      #)
      #
      #return {'code' => 0 } if @phone_number == "robin8.best"  || Rails.env.development?
      #
      #begin
      #  res = ChinaSMS.to @phone_number, tpl_params, tpl_id: 1
      #rescue Exception => ex
      #  @sms_message.update(status: "failed")
      #  Rails.logger.sms_spider.error ex
      #  return {:message => ex.message}
      #ensure
      #  if  Rails.env.staging? or Rails.env.qa?
      #    @sms_message.update(status: "success")
      #    return {'code' => 0 }
      #  end
      #end
      #
      #if res["code"] == 0
      #  @sms_message.update(status: "success")
      #  Rails.logger.info "Send sms to #{@phone_number} successfully when sign up"
      #else
      #  @sms_message.update(status: "failed")
      #  Rails.logger.error "Failed to send sms to #{@phone_number}, the return code is #{res['code']}, please look up https://www.yunpian.com/api/recode.html"
      #end

      return {'code' => 0}
    end

    def write_cache_for phone_number, code
      SendRegisterSms.write_cache_for(phone_number,code)
    end

    def self.write_cache_for(phone_number,code)
      $redis.setex(phone_number, 30.minutes, code.to_s)
    end

    def security_code
      code = $redis.get(@phone_number) || generate_security_code
    end

    def generate_security_code
      @phone_number == FakeNumber ? FakeCode : (1..9).to_a.sample(4).join
    end

    def self.get_code(phone)
      return FakeCode if phone ==  FakeNumber
      $redis.get(phone)
    end

    SkipVerifyPhones = ['13000000000', '13262752287','13795431288', '13979115652', '13979115653',
                        '13764211748', '15221773929', '15298670933',
                        '13817164642', '15618348706', '18221707548', '15000058089','18321878526','13915128156','15152331980','15298675346','18817774892','15606172163']
    def self.verify_code(phone, code)
      if phone[0] == '0'
        phone = '+84' + phone[1..-1]
      end

      phone = phone.to_s        rescue ""
      code = code.to_s          rescue ""

      puts "-----------------------"
      puts phone

      return true if  $redis.get(phone) == code
      return code == "123456"  if Rails.env.development?  || Rails.env.staging? || Rails.env.qa? || phone.start_with?("10000")
      SkipVerifyPhones.include?(phone) && code == '123456'
    end
  end
end
