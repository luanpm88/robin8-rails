class AddColumnOcrStatusToCampaignInvite < ActiveRecord::Migration
  def change
    add_column :campaign_invites, :ocr_status, :string
    add_column :campaign_invites, :ocr_detail, :string
  end
end
