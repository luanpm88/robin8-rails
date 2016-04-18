class AddUniqueIndexForCampaignInvite < ActiveRecord::Migration
  def change
    change_column :campaign_invites, :uuid, :string, :limit => 100
    add_index :campaign_invites,  :uuid, :unique => true
  end
end
