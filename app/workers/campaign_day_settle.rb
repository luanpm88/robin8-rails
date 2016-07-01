class CampaignDaySettleWorker
  include Sidekiq::Worker

  def perform
    CampaignInvite.schedule_day_settle
  end
end
