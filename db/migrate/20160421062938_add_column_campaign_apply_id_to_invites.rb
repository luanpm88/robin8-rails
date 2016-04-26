class AddColumnCampaignApplyIdToInvites < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :campaign_apply_id, :integer
  end
end
