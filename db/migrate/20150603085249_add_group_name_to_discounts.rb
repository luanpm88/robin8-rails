class AddGroupNameToDiscounts < ActiveRecord::Migration
  def change
    add_column :discounts, :group_name, :string
  end
end
