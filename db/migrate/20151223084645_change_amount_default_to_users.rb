class ChangeAmountDefaultToUsers < ActiveRecord::Migration
  def change
    change_column :users, :amount, :decimal, :precision => 12, :scale => 2, :default => 100
  end
end
