class AlizhongbaoCompleteShareWorker
  include Sidekiq::Worker

  def perform(kol_id, campaign_id)
    Partners::Alizhongbao.completed_share(kol_id, campaign_id)
  end
end
