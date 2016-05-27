class CampaignObserverWorker
  include Sidekiq::Worker
  sidekiq_options  :queue => :campaign_observer_worker

  def perform(campaign_id)
    CampaignInvite.where(:campaign_id => campaign_id).map do |invite|
      campaign = Campaign.where(:id => invite.campaign_id, :status => ['executed','settled']).first
      next unless campaign
      if invite.observer_status != 0
        next
      end
      invalid_reasons = CampaignObserver.observer_campaign_and_kol campaign_id, invite.kol_id
      if invalid_reasons.present?
        invite.update(:observer_status => 2, :observer_text => invalid_reasons.join("\n"))
      else
        invite.update(:observer_status => 1)
      end
    end
  end
end