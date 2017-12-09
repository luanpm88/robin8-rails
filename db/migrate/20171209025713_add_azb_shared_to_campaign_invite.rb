class AddAzbSharedToCampaignInvite < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :azb_shared, :boolean
  end
end
