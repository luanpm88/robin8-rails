class AddColumnAutoCheckToCampaignInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :auto_check, :boolean, :default => false
  end
end
