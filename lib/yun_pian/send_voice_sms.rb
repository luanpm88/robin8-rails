module YunPian
  class SendVoiceSms
    FakeNumber = 'robin8.best'
    FakeCode = '1234'
    VoiceServer = "https://voice.yunpian.com/v1/voice/send.json"

    def initialize(phone_number,
                   api_key = Rails.application.secrets.yunpian[:api_key],
                   company_sign = Rails.application.secrets.yunpian[:company_sign])
      @phone_number = phone_number.to_s
      @api_key = api_key
      @company_sign = company_sign
    end


    def send_sms
      return if @phone_number.blank?
      return {'code' => 1, :msg => "发送频繁，请稍后再试"} if  !check_rule?
      return {'code' => 0 } if Rails.env.development?
      set_security_code
      result = send_request
      Rails.logger.sms.info "-----void_sms:  #{result.inspect}"
      return result
    end

    def send_request
      options = {:mobile => @phone_number, :apikey => @api_key, :code => @code}
      @sms_message = SmsMessage.create(
        phone: @phone_number,
        content: "语音验证码：#{options[:code]}",
        mode: "verified_code",
        status: "success"
      )
      res = Net::HTTP.post_form(URI.parse(VoiceServer), options)
      begin
        JSON.parse res.body
      rescue => e
        @sms_message.update(status: "failed")

        {
          code: 502,
          msg: "内容解析错误",
          detail: e.to_s
        }
      end
    end

    def get_key
      "voice_sms_#{@phone_number}"
    end

    # 过滤规则：同1个手机发相同内容，30秒内最多发送1次，5分钟内最多发送3次。
    def check_rule?
      records = Rails.cache.read(get_key)
        # 30秒内最多发送1次
      if records && records.last[:send_time] > Time.now - 30.seconds
        return false
        # 5分钟内最多发送3次。
      elsif records && records.first[:send_time] > Time.now + 5.minutes && records.size == 3
        return false
      else
        return true
      end
    end

    def add_history
      records = (Rails.cache.read("voice_sms_#{@phone_number}"))[-2,2] || []  rescue []
      records << {:send_time => Time.now, :code => @code}
      Rails.cache.write(get_key, records, :expires_in => 10.minutes)
    end

    def set_security_code
      @code = (1..9).to_a.sample(4).join
      YunPian::SendRegisterSms.write_cache_for(@phone_number,@code)
      add_history
    end

  end
end
