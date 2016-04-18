class AddOtherOptionsToCampaignShows < ActiveRecord::Migration
  def change
    add_column :campaign_shows, :other_options, :string
  end
end
