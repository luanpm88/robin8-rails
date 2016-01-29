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
      begin
        res = ChinaSMS.to @phone_number, '【罗宾科技】您上传的任务截图未通过审核，请打开已接受活动查看截图范例并重新上传。'
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
        res = ChinaSMS.to @phone_number, tpl_params, tpl_id: 1200383
      rescue Exception => ex
        Rails.logger.error ex
        return nil
      end
    end
  end
end
