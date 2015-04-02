class AddDiscountsModuleAndAssociations < ActiveRecord::Migration
  def change
    create_table :discounts do |t|
      t.string :code
      t.string :description
      t.string :status
      t.integer :amount
      t.float :percentage
      t.datetime :expiry
      t.integer :max_count
      t.boolean :is_active,:default => true
      t.timestamps null: false
    end

    create_table :user_discounts do |t|
      t.integer :user_id
      t.integer :discount_id
      t.boolean :is_used,:boolean=>false
      t.timestamps null: false
    end

    create_table :product_discounts do |t|
      t.integer :product_id
      t.integer :discount_id
      t.timestamps null: false
    end

    add_column :payments,:discount_id,:integer

  end
end
