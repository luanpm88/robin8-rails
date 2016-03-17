# encoding: utf-8
module Emay
  class SendSms
    EmayServer = Rails.application.secrets.emay[:server]
    EmayName = Rails.application.secrets.emay[:name]
    EmayPassword = Rails.application.secrets.emay[:password]

    #content 一点要封装前后缀
    def self.to(phone, content)
      content = TemplateContent.get_content(content)
      phones = Array(phone).join(',')
      res = Net::HTTP.post_form(URI.parse(EmayServer), cdkey: EmayName, password: EmayPassword, phone: phones, message: content)
      Rails.logger.info "---------emay----#{phone}---result:#{res.inspect}"
      result res.body
    end

    def self.result(body)
      code = body.match(/.+error>(.+)\<\/error/)[1]
      {
        success: (code.to_i >= 0),
        code: code
      }
    end

    def self.test(mobiles='13817164642', content='http://www.baidu.com')
      content = TemplateContent.get_invite_sms(mobiles,content)
      result = self.to mobiles, content
      result
    end
  end
end
