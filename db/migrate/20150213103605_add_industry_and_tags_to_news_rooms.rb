class AddIndustryAndTagsToNewsRooms < ActiveRecord::Migration
  def change
    add_column :news_rooms, :industry, :text
    add_column :news_rooms, :tags, :text
  end
end
