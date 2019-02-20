class AddStatusToTrademarks < ActiveRecord::Migration
  def change
    add_column :trademarks, :status, :integer, default: 1
  end
end
