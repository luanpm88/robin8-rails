class ChangeAppliableCreditsTypeToUser < ActiveRecord::Migration
  def up
    change_column :users, :appliable_credits, :decimal, precision: 12, scale: 2, default: 0
  end

  def down
    change_column :users, :appliable_credits, :integer, default: 0
  end
end
