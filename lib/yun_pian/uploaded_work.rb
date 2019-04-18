module YunPian
  class UploadedWork

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
        res = ChinaSMS.to @phone_number, {}, tpl_id: 2834146
      rescue Exception => ex
        Rails.logger.error ex
        return nil
      end
    end

  end
end