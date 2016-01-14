class CampaignInviteSmsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(mobile_numbers, status)
    str = ""
    mobile_numbers.each do |m|
      str << m << ','
    end

    sms_client = YunPian::SendCampaignInviteResultSms.new(str, status)
    sms_client.send_reject_sms
  end
end
