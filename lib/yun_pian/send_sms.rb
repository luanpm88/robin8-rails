# encoding: utf-8
module YunPian
  class SendSms
    SMS_TEMPLATE = {:code => '2'}
    ChinaSMS.use :yunpian, password: Rails.application.secrets.yunpian[:api_key]

    FAKE_PHONE = {
      '0006' => '13817164642'
    }

    # 发送验证码短信
    def self.send_code(mobile, code)
    end

    # 发送模版短信
    def self.send_with_tpl(mobile, tpl_key, code)
      return false if SMS_TEMPLATE[tpl_key.to_sym].nil?
      if code.is_a? String
        send(mobile, nil, tpl_key, {:code => code})
      elsif code.is_a? Hash
        send(mobile, nil, tpl_key, code)
      end
    end


    # 发送一般短信 短信内容需要审核通过
    def self.send_msg(mobiles, content = '')
      send(mobiles, content)
    end

    def self.fake_phone(phone)
      FAKE_PHONE[phone[0, 4]] || phone
    end

    private
    #mobile 可以为一个 也可以为多个
    def self.send(mobile, content = '', tpl_key = '', tpl_params = {})
      if tpl_key.present? && tpl_params.present?
        # 发送模版短信
        result = ChinaSMS.to mobile, tpl_params, tpl_id: SMS_TEMPLATE[tpl_key.to_sym]
      else
        result = ChinaSMS.to mobile, content
      end
      Rails.logger.info "---------yunpian----#{mobile}---result:#{result.inspect}"
      result
    end
  end
end
