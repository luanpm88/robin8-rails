class AddColumnAccountInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :amount, :decimal, :precision => 12, :scale => 2, :default => 50
    add_column :users, :frozen_amount, :decimal, :precision => 12, :scale => 2, :default => 0

    add_column :kols, :amount, :decimal, :precision => 12, :scale => 2, :default => 0
    add_column :kols, :frozen_amount, :decimal, :precision => 12, :scale => 2, :default => 0
  end
end
