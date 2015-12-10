class CampaignWorker
  include Sidekiq::Worker

  def perform(*args)
    campaign_id = args[0]
    job_type = args[1]
    logger.info "--------#{campaign_id}--job_type:#{job_type}---"
    campaign = Campaign.find(campaign_id)   rescue nil
    return false if campaign.nil?
    if job_type == 'start'
      campaign.go_start
    elsif job_type == 'end'
      campaign.finish('expired') if campaign.status != 'executed'
    elsif job_type == 'send_invites'
      campaign.send_invites
    end
  end

end
