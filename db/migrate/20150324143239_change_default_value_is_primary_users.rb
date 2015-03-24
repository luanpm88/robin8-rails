class ChangeDefaultValueIsPrimaryUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :is_primary, true
  end
end
