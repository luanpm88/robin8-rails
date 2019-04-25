class ChangeTransactionsCreditsColumn < ActiveRecord::Migration
  def change
    change_column :transactions, :credits, :decimal, :precision => 16, :scale => 2
    change_column :transactions, :amount, :decimal, :precision => 16, :scale => 2
    change_column :transactions, :avail_amount, :decimal, :precision => 16, :scale => 2
    change_column :transactions, :frozen_amount, :decimal, :precision => 16, :scale => 2
  end
end
