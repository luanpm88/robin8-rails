class InitApprovingCampaignIdsFromInvites < ActiveRecord::Migration
  def change
    #删除以前无效 invites
    CampaignInvite.where("uuid is null and id < 163 ").delete_all
    # 历史无上传截图的 (status 还是rejected)
    CampaignInvite.joins(:campaign).where("campaign_invites.status = 'finished' and campaign_invites.img_status ='rejected' and campaigns.status='settled'").each do |campaign_invite|
      campaign_invite.status = 'rejected'
      campaign_invite.save
    end
    Kol.find_each do |kol|
      puts "---kol_id:#{kol.id}"
      # add campaign_id to kol receive_campaign list
      CampaignInvite.where(:kol_id => kol.id).collect{|invite| invite.campaign_id }.each do |campaign_id|
        kol.add_campaign_id(campaign_id)
      end

      # remove history rejected status as miss and get running from redis
      CampaignInvite.where(:kol_id => kol.id).where("status = 'rejected'  or status ='pending'").delete_all
    end

  end
end
