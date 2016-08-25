class AddIndexToCamapignShows < ActiveRecord::Migration
  def change
    add_index :campaign_shows, :campaign_id
    add_index :campaign_shows, :created_at
  end
end
