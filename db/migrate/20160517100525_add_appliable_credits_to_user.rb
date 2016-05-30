class AddAppliableCreditsToUser < ActiveRecord::Migration
  def change
    add_column :users, :appliable_credits, :integer, default: 0
  end
end
