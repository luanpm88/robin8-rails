class AddPreviewToNewsRooms < ActiveRecord::Migration
  def change
    add_column :news_rooms, :parent_id, :integer
  end
end