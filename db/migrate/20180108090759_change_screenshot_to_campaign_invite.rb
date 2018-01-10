class ChangeScreenshotToCampaignInvite < ActiveRecord::Migration
  def change
  	change_column :campaign_invites, :screenshot, :string, limit: 512
  end
end
