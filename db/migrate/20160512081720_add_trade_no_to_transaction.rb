class AddTradeNoToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :trade_no, :string, default: nil, limit: 191
    add_index :transactions, :trade_no, :unique => true
  end
end
