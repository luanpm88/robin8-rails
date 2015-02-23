class AddDefaultNewsRoomFieldToNewsRooms < ActiveRecord::Migration
  def change
    add_column :news_rooms, :default_news_room, :boolean, default: false
  end
end
