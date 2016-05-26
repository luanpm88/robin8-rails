class AddColumnRequestUrlToCampaignShows < ActiveRecord::Migration
  def change
    add_column :campaign_shows, :request_url, :string
  end
end
