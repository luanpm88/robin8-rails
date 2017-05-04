class AddColumnLockVersionToCampaignInvite < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :lock_version, :integer, :default => 0, :null => false
  end
end
