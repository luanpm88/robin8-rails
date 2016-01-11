class CampaignInviteSmsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(campaign_invites)
    str = ""
    campaign_invites.each do |c|
      str << c.kol.mobile_number << ',' if c.kol.mobile_number
    end

    sms_client = YunPian::SendCampaignInviteResultSms.new(str)
    sms_client.send_reject_sms
  end
end
