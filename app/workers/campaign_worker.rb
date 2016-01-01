class CampaignWorker
  include Sidekiq::Worker
  sidekiq_options  :queue => :campaign

  def perform(*args)
    campaign_id = args[0]
    job_type = args[1]
    Rails.logger.campaign_sidekiq.info "-----CampaignWorker: perform  --#{campaign_id}--job_type:#{job_type}----------"
    sleep 2
    campaign = Campaign.find(campaign_id)   rescue nil
    # counter = 0
    # while campaign.nil? && counter < 10
    #   sleep 0.3
    #   counter += 1
    #   campaign = Campaign.find(campaign_id)   rescue nil
    # end
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
