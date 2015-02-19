class AddLogoUrlToNewsRooms < ActiveRecord::Migration
  def change
     add_column :news_rooms, :logo_url, :string
  end
end
