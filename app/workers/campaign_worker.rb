class CampaignWorker
  include Sidekiq::Worker

  def perform(*args)
    campaign_id = args[0]
    job_type = args[1]
    logger.info "--------#{campaign_id}--job_type:#{job_type}---"
    campaign = Campaign.find(campaign_id)   rescue nil
    return false if campaign.nil?
    if job_type == 'start'
      campaign.update_attribute(:status, 'executing')
      campaign.send_invites
    else
      campaign.finish('expired') if campaign.status != 'executed'
    end
  end

end
