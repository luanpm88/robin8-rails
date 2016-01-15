class UpdateOriginCampaignStatus < ActiveRecord::Migration
  def change
    Campaign.where(:status => 'executed').update_all(:status => 'settled')
    CampaignInvite.where(:status => 'finished').update_all(:status => 'settled', :img_status => 'passed')
  end
end
