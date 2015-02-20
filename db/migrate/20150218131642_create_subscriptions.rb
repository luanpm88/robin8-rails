class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :package_id
      t.string :status
      t.string :cancellation_reason
      t.string :underlying_sku_id
      t.string :shopper_id
      t.float :recurring_amount
      t.string :recurring_currency
      t.date :next_charge_date
      t.boolean :auto_renew,:default=>true

      t.timestamps null: false
    end
  end
end
