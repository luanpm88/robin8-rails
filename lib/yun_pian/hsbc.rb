module YunPian
  class Hsbc
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
      ChinaSMS.use :yunpian, password: @api_key
      begin
        res = ChinaSMS.to @phone_number, {}, tpl_id: 2551120
      rescue Exception => ex
        Rails.logger.error ex
        return nil
      end
    end

    # 营销短信 api_key: 'e95a756756c5b0d28968be9cb23eb535'
    def send_kangyu_sms
      return if @phone_number.blank?
      ChinaSMS.use :yunpian, password: 'e95a756756c5b0d28968be9cb23eb535'
      begin
        res = ChinaSMS.to @phone_number, {}, tpl_id: 2585964
      rescue Exception => ex
        Rails.logger.error ex
        return nil
      end
    end

  end
end