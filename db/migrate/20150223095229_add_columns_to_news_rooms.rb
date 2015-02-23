class AddColumnsToNewsRooms < ActiveRecord::Migration
  def change
    add_column :news_rooms, :toll_free_number, :string
  end
end
