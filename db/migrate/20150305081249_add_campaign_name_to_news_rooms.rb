class AddCampaignNameToNewsRooms < ActiveRecord::Migration
  def change
    add_column :news_rooms, :campaign_name, :string

    add_index :news_rooms, :campaign_name
  end
end
