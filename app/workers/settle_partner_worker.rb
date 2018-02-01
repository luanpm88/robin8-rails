class SettlePartnerWorker
  include Sidekiq::Worker

  def self.perform(id , channel = "azb")
  	CampaignInvite.joins(:kol).where("kols.channel = ? AND campaign_invites.campaign_id = ?" , channel , id).each do |t|
  	  Partners::Alizhongbao.settle_campaign_invite(t.id)
  	end
  end
end