class AddCampaignFromToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :camapign_from, :string, default: 'pc'
  end
end
