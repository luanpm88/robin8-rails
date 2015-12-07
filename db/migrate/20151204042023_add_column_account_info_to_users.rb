class AddColumnAccountInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :amount, :decimal, :precision => 8, :scale => 2, :default => 50
    add_column :users, :frozen_amount, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end
