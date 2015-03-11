class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.integer :subscription_id
      t.integer :package_id
      t.string :encrypted_card_number
      t.string :card_last_four_digits
      t.string :card_type
      t.integer :expiration_month
      t.integer :expiration_year
      t.integer :order_id
      t.string :encrypted_security_code
      t.string :coupon
      t.string :charged_amount
      t.string :total_amount
      t.string :status
      t.string :last_charge_result

      t.timestamps null: false
    end
  end
end
