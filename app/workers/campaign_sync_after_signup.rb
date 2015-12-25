class CampaignSyncAfterSignup
  include Sidekiq::Worker

  def perform(kol_id)
    try_count = 0
    kol = Kol.where(:id => kol_id).first

    while true
      break if kol.present? or try_count > 10
      sleep 3
      kol = Kol.where(:id => kol_id).first
      try_count += 1
    end

    return unless kol.present?

    Campaign.where(:status => :agreed).each do |campaign|
      unless CampaignInvite.exists?(:kol_id => kol_id, :campaign_id => campaign.id)
        campaign.send_invite_to_kol kol, "pending"
      end
    end

    Campaign.where(:status => :executing).each do |campaign|
      unless CampaignInvite.exists?(:kol_id => kol_id, :campaign_id => campaign.id)
        campaign.send_invite_to_kol kol, "running"
      end
    end
  end
end