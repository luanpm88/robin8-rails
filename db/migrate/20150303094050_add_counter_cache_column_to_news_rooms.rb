class AddCounterCacheColumnToNewsRooms < ActiveRecord::Migration
  def change
    add_column :news_rooms, :releases_count, :integer, :null => false, :default => 0
  end
end
