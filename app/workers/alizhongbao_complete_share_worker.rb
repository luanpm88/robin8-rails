class AlizhongbaoCompleteShareWorker
  include Sidekiq::Worker

  def perform(campaign_invite_id)
    Partners::Alizhongbao.completed_share(campaign_invite_id)
  end
end
