class RemovePaymentIdFromUserAddOns < ActiveRecord::Migration
  def change
    remove_column :user_add_ons,:payment_id
  end
end
