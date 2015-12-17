class AddApprovedAtToCampaignInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :approved_at, :datetime
  end
end
