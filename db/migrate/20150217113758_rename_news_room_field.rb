class RenameNewsRoomField < ActiveRecord::Migration
  def change
    rename_column :releases, :newsroom_id, :news_room_id
  end
end
