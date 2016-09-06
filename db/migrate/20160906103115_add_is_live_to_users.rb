class AddIsLiveToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_live, :boolean, default: true
  end
end
