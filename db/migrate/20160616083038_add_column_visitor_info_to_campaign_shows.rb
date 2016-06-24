class AddColumnVisitorInfoToCampaignShows < ActiveRecord::Migration
  def change
    add_column :campaign_shows, :appid, :string
    add_column :campaign_shows, :device_model, :string
    add_column :campaign_shows, :app_platform, :string
    add_column :campaign_shows, :os_version, :string
    add_column :campaign_shows, :reg_time, :datetime

    add_index :campaign_shows, :appid
  end
end
