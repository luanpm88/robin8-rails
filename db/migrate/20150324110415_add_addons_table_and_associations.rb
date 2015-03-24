class AddAddonsTableAndAssociations < ActiveRecord::Migration
  def change
    create_table :add_ons do |t|
      t.string :name
      t.string :description
      t.float :price
      t.boolean :is_active,:default => true
      t.timestamps null: false
    end

    create_table :user_add_ons do |t|
      t.integer :add_on_id
      t.integer :user_id
      t.datetime :expiry
      t.integer :used_count,:default => 0
      t.integer :available_count,:default => 1
      t.string :status
      t.float :charged_amount
      t.integer :payment_id
      t.timestamps null: false
    end

  end
end
