class ChangeColumnIsHotToInt < ActiveRecord::Migration
  def change
    change_column :kols, :is_hot, :integer, :default => 0
  end
end
