class CampaignDaySettleWorker
  include Sidekiq::Worker

  def perform
    CampaignInvite.day_settle
  end
end
