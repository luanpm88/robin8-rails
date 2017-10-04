class AddIndexToCampaigns < ActiveRecord::Migration
  def change
    add_index :campaign_invites, [:deleted, :campaign_id, :status]
  end
end
