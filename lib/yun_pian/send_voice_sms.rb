module YunPian
  class SendVoiceSms
    FakeNumber = 'robin8.best'
    FakeCode = '1234'
    VoiceServer = "https://sms.yunpian.com/v1/sms/send.json"

    def initialize(phone_number,
                   api_key = Rails.application.secrets.yunpian[:api_key],
                   company_sign = Rails.application.secrets.yunpian[:company_sign])
      @phone_number = phone_number
      @api_key = api_key
      @company_sign = company_sign
    end


    def send_sms
      return if @phone_number.blank?
      return {'code' => 1, :msg => "发送频繁，请稍后再试"} if  !check_rule?
      return {'code' => 0 } if Rails.env.development?
      set_security_code
      return send_request
    end

    def send_request
      options = {:mobile => @phone_number, :apikey => @api_key, :text => @code}
      res = Net::HTTP.post_form(URI.parse(VoiceServer), options)
      begin
        JSON.parse res
      rescue => e
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
      if records && records.last.send_time > Time.now - 30.seconds
        return false
        # 5分钟内最多发送3次。
      elsif records && records.first > Time.now + 5.minutes && records.size == 3
        return false
      else
        return true
      end
    end

    def add_rule
      records = Rails.cache.read("voice_sms_#{@phone_number}")[-2,2]
      records << {:send_time => Time.now, :code => @code}
      Rails.cache.write(get_key, :expires_in => 10.minutes)
    end

    def set_security_code
      @code = (1..9).to_a.sample(4).join
      add_rule
    end

  end
end
