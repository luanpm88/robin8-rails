class ChangeTransactionsCreditsColumn < ActiveRecord::Migration
  def change
    change_column :transactions, :credits, :decimal, :precision => 16, :scale => 2
    change_column :amount, :credits, :decimal, :precision => 16, :scale => 2
  end
end
