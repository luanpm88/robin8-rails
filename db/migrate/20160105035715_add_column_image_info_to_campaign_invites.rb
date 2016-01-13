class AddColumnImageInfoToCampaignInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :img_status, :string, :default => 'pending'
    add_column :campaign_invites, :screenshot, :string
    add_column :campaign_invites, :reject_reason, :string
  end
end
