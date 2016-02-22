class InitApprovingCampaignIdsFromInvites < ActiveRecord::Migration
  def change
    Kol.find_each do |kol|
      puts "---kol_id:#{kol.id}"
      CampaignInvite.where(:kol_id => kol.id).collect{|invite| invite.campaign_id }.each do |campaign_id|
        kol.add_campaign_id(campaign_id)
      end
    end
  end
end
