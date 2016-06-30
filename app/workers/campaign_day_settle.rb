class CampaignDaySettleWorker
  include Sidekiq::Worker

  def perform(deadline)
    CampaignInvite.day_settle(deadline)
  end
end
