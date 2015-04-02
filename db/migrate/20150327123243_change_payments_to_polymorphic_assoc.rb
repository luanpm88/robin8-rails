class ChangePaymentsToPolymorphicAssoc < ActiveRecord::Migration
  def migrate(direction)
    super
    Payment.update_all(payable_type: "Subscription") if direction == :up
    Payment.update_all(orderable_type: "Package") if direction == :up
  end
  def change
    rename_column :payments,:subscription_id,:payable_id
    add_column :payments,:payable_type,:string

    rename_column :payments,:package_id,:orderable_id
    add_column :payments,:orderable_type,:string
  end
end
