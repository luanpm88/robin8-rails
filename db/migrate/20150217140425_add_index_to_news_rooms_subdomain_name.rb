class AddIndexToNewsRoomsSubdomainName < ActiveRecord::Migration
  def change
    add_index :news_rooms, :subdomain_name
  end
end
