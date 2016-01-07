module YunPian
  class SendCampaignInviteResultSms
    def initialize(phone_number, status=nil,
                   api_key = Rails.application.secrets.yunpian[:api_key])
      @phone_number = phone_number
      @status = status
      @api_key = api_key
    end

    def send_reject_sms
      return if @phone_number.blank?
      ChinaSMS.use :yunpian, password: @api_key
      if @status == "reject"
        tpl_params = {result: "未通过", to_do: "重新上传截图"}
      end
      begin
        res = ChinaSMS.to @phone_number, tpl_params, tpl_id: 1200383
      rescue Exception => ex
        Rails.logger.error ex
        return nil
      end
    end

    def send_campaign_finished_sms
      return if @phone_number.blank?
      ChinaSMS.use :yunpian, password: @api_key
      tpl_params = {count: '3'}
      begin
        res = ChinaSMS.to @phone_number, tpl_params, tpl_id: 1199525
      rescue Exception => ex
        Rails.logger.error ex
        return nil
      end
    end
  end
end
