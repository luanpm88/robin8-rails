class AddUniqueIndexToColumnToUserName < ActiveRecord::Migration
  def change
    change_column :users, :name, :string, limit: 191
    add_index :users, :name, unique: true
  end
end
