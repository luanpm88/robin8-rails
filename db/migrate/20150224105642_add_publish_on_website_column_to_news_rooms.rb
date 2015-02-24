class AddPublishOnWebsiteColumnToNewsRooms < ActiveRecord::Migration
  def change
    add_column :news_rooms, :publish_on_website, :boolean, default: false
  end
end
