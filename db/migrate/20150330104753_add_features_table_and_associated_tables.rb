class AddFeaturesTableAndAssociatedTables < ActiveRecord::Migration
  def change

    create_table :features do |t|
      t.string :name
      t.string :description
      t.string :slug
      t.boolean :is_active,:default => true
      t.timestamps null: false
    end

    create_table :product_features do |t|
      t.integer :product_id
      t.integer :feature_id
      t.integer :validity
      t.integer :count,:default => 1
      t.timestamps null: false
    end

    create_table :user_features do |t|
      t.integer :user_id
      t.integer :feature_id
      t.integer :product_id
      t.integer :used_count,:default => 0
      t.integer :max_count
      t.date :reset_at
      t.integer :count,:default => 1
      t.timestamps null: false
    end

    rename_table :packages ,:products
    add_column :products,:is_package, :boolean, :default=>false

  end
end
