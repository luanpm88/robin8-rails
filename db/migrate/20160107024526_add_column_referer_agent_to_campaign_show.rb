class AddColumnRefererAgentToCampaignShow < ActiveRecord::Migration
  def change
    add_column :campaign_shows, :visitor_agent, :string, :limit => 3555
    add_column :campaign_shows, :visitor_referer, :string, :limit => 3555
  end
end
