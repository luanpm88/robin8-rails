class AddDeletedToCampaignInvite < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :deleted, :boolean, default: false
    add_index :campaign_invites, :deleted
  end
end
