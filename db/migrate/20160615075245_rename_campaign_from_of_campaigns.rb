class RenameCampaignFromOfCampaigns < ActiveRecord::Migration
  def change
    rename_column :campaigns, :camapign_from, :campaign_from
  end
end
