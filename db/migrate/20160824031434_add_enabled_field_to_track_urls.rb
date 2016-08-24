class AddEnabledFieldToTrackUrls < ActiveRecord::Migration
  def change
    add_column :track_urls, :enabled, :boolean, :default => true
  end
end
