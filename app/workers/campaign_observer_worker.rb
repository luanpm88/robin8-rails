class CampaignObserverWorker
  include Sidekiq::Worker
  sidekiq_options  :queue => :campaign_observer_worker

  def perform(campaign_id)
    campaign = Campaign.where(:id => campaign_id, :status => ['executed','settled']).first rescue nil
    if campaign
      campaign_invite campaign_id
    else
      ::NewRelic::Agent.record_metric("CampaignObserverWorker / campaign_id:#{campaign_id} not found. Worker not running", campaign_id)
      return nil
    end
  end

  def campaign_invite campaign_id
    CampaignInvite.where(:campaign_id => campaign_id).map do |invite|
      if invite.observer_status != 0
        next
      end
      invalid_reasons = CampaignObserver.observer_campaign_and_kol campaign_id, invite.kol_id
      retries = true
      begin
        if invalid_reasons.present?
          invite.update(:observer_status => 2, :observer_text => invalid_reasons.join("\n"))
        else
          invite.update(:observer_status => 1)
        end
      rescue ActiveRecord::StaleObjectError => e
        if retries == true
          retries = false
          invite.reload
          retry
        else
          ::NewRelic::Agent.record_metric('Robin8/Errors/CampaignObserverWorker/ActiveRecord::StaleObjectError', e)
        end
      end
    end
  end
end
