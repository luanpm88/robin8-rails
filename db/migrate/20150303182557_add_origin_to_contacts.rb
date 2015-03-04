class AddOriginToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :origin, :integer, default: 0, limit: 1
  end
end
