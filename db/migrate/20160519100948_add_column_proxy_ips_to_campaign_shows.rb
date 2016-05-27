class AddColumnProxyIpsToCampaignShows < ActiveRecord::Migration
  def change
    add_column :campaign_shows, :proxy_ips, :string
  end
end
