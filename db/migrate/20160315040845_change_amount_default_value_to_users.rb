class ChangeAmountDefaultValueToUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :amount, 0
  end
end
