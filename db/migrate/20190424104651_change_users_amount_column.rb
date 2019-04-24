class ChangeUsersAmountColumn < ActiveRecord::Migration
  def change
    change_column :users, :amount, :decimal, :precision => 16, :scale => 2
  end
end
