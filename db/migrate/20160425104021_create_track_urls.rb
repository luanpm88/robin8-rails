class CreateTrackUrls < ActiveRecord::Migration
  def change
    create_table :track_urls do |t|
      t.string  :origin_url
      t.string  :short_url
      t.string  :desc
      t.integer :click_count, :default => 0
      t.timestamps null: false
    end
  end
end
