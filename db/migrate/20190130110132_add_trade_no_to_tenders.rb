class AddTradeNoToTenders < ActiveRecord::Migration
  def change
    add_column :tenders, :trade_no, :string
  end
end
