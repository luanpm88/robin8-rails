class CampaignWorker
  include Sidekiq::Worker

  def perform(campaign_id, job_type)
    campaign = Campaign.find(campaign_id)   rescue nil
    return false if campaign.nil?
    if job_type == 'start'
      Kol.all.each do |kol|
        invite = CampaignInvite.new
        invite.status = ''
        invite.compaign_id = campaign_id
        invite.kol_id = kol.id
        uuid = Base64.encode({:compaign_id => campaign_id, :kol_id=> kol_id})
        invite.uuid = uuid
        invite.share_url = CampaignInvite.generate_share_url(uuid)
        invite.save!
      end
    else
      campaign.finish('expired') if campaign.status != 'executed'
    end
  end
end
