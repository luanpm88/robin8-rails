class AddSubdomainToNewsRooms < ActiveRecord::Migration
  def change
    add_column :news_rooms, :subdomain_name, :string
  end
end
