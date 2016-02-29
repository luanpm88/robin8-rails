class AddUuidColumnsToCampaignActionUrl < ActiveRecord::Migration
  def change
    add_column :campaign_action_urls, :uuid, :string
  end
end
