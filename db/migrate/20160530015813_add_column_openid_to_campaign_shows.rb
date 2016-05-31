class AddColumnOpenidToCampaignShows < ActiveRecord::Migration
  def change
    add_column :campaign_shows, :openid, :string
  end
end
