class AddIndexToCampaignInvites < ActiveRecord::Migration
  def change
    add_index :campaign_invites, :img_status
  end
end
