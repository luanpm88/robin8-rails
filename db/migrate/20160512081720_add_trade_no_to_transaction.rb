class AddTradeNoToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :trade_no, :string, default: nil, limit: 191
    add_column :transactions, :after_tax_credits, :string, default: nil
    add_index :transactions, :trade_no, :unique => true
  end
end
