class CampaignWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :campaign, :retry => 3
  sidekiq_retry_in do |count|
    60 * (count + 1)
  end

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
    elsif job_type == 'end_apply_check'
      CampaignApply.end_apply_check(campaign_id)
    elsif job_type == 'settle_accounts_for_kol'
      campaign.settle_accounts_for_kol
    elsif job_type == 'settle_accounts_for_brand'
      campaign.settle_accounts_for_brand
    elsif job_type == 'fee_end'
      campaign.finish('fee_end') if campaign.status != 'executed'
    elsif job_type == 'remind_upload'
      campaign.remind_upload
    elsif job_type == "timed_append_kols"
      campaign.timed_append_kols
    elsif job_type == "push_all_kols"
      campaign.push_all_kols
    elsif job_type == "countdown"
      campaign.campaign_countdown
    end
  end

end
