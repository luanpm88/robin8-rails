class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.integer :package_id
      t.string :status
      t.string :cancellation_reason
      t.string :shopper_id
      t.float :recurring_amount
      t.float :charged_amount
      t.float :total_amount
      t.date :next_charge_date
      t.boolean :auto_renew,:default=>true

      t.timestamps null: false
    end
  end
end
