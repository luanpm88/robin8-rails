class AddUniqueIndexToSubdomainNameField < ActiveRecord::Migration
  def change
    add_index :news_rooms, :subdomain_name, :unique => true
  end
end
