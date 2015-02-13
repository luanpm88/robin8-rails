class RemoveIndustryColumnFromNewsRooms < ActiveRecord::Migration
  def change
    remove_column :news_rooms, :industry
  end
end
