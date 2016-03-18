class AddIdentifierColumnToCampaignActionUrl < ActiveRecord::Migration
  def change
    add_column :campaign_action_urls, :identifier, :string
    remove_column :campaign_action_urls, :user_id, :integer
    remove_column :campaign_action_urls, :uuid, :string
  end
end
