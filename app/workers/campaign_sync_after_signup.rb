class CampaignSyncAfterSignup
  include Sidekiq::Worker

  def perform(kol_id)
    try_count = 0
    kol = Kol.where(:id => kol_id).first

    while true
      break if kol.present? or try_count > 3
      sleep 3
      kol = Kol.where(:id => kol_id).first
      try_count += 1
    end

    return unless kol.present?

    Campaign.where(:status => :agreed).each do |campaign|
      kol.add_campaign_id campaign.id
    end

    Campaign.where(:status => :executing).each do |campaign|
      kol.add_campaign_id campaign.id
    end
  end
end
