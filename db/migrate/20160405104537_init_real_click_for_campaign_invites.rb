class InitRealClickForCampaignInvites < ActiveRecord::Migration
  def change
    CampaignInvite.all.each do |campaign_invite|
      campaign_invite.redis_real_click.reset  campaign_invite.redis_avail_click
    end
  end
end
