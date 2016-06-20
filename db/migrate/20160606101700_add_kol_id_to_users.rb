class AddKolIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :kol_id, :integer
  end
end
