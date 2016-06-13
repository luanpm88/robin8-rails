class AddColumnUploadTimeCheckTimeToCampaignInvite < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :upload_time, :datetime
    add_column :campaign_invites, :check_time, :datetime
  end
end
