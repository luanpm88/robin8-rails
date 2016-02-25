class InitApprovingCampaignIdsFromInvites < ActiveRecord::Migration
  def change
    Kol.find_each do |kol|
      puts "---kol_id:#{kol.id}"
      # add campaign_id to kol receive_campaign list
      CampaignInvite.where(:kol_id => kol.id).collect{|invite| invite.campaign_id }.each do |campaign_id|
        kol.add_campaign_id(campaign_id)
      end

      # remove history rejected status as miss
      CampaignInvite.where(:kol_id => kol.id, :status => 'rejected').delete_all
    end
  end
end
