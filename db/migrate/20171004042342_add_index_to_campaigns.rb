class AddIndexToCampaigns < ActiveRecord::Migration
  def self.up
    add_index :campaign_invites, [:deleted, :campaign_id, :status]
  end

  def self.down
    remove_index :campaign_invites, [:deleted, :campaign_id, :status]
  end
end
