class ChangeUsersAmountColumn < ActiveRecord::Migration
  def change
    change_column :users, :amount, :decimal, :precision => 16, :scale => 2
    change_column :users, :frozen_amount, :decimal, :precision => 16, :scale => 2
    change_column :users, :appliable_credits, :decimal, :precision => 16, :scale => 2
  end
end
