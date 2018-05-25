class AddTradeNoToCredit < ActiveRecord::Migration
  def change
  	add_column :credits, :trade_no, :string, default: nil, limit: 191
  end
end
