class ChangeCampaignActionUrlColumns < ActiveRecord::Migration
  def change
    rename_column :campaign_action_urls, :kol_id, :user_id
  end
end
