class CampaignSmsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false

  def perform(campaign_id)
    mobile_numbers = Kol.joins(:campaigns, :campaign_invites).where("campaign_invites.avail_click > ? AND campaigns.id = ? AND mobile_number != ?", 0, campaign_id, "").distinct.pluck(:mobile_number)
    mobile_numbers.each_slice(800) do |batch|
      str = ""
      batch.each do |number|
        str << number << ','
      end

      sms_client = YunPian::SendCampaignInviteResultSms.new(str)
      sms_client.send_campaign_finished_sms
    end
  end
end
