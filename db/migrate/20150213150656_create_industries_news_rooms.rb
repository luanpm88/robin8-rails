class CreateIndustriesNewsRooms < ActiveRecord::Migration
  def change
    create_table :industries_news_rooms do |t|
      t.references :industry
      t.references :news_room
    end
    add_index :industries_news_rooms, :industry_id
    add_index :industries_news_rooms, :news_room_id
  end
end
