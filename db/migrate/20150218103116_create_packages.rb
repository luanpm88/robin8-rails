class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :slug
      t.boolean :is_active,:default=>false
      t.float :price
      t.string :status
      t.integer :interval
      t.string :name
      t.integer :sku_id
      t.string :description
      t.timestamps null: false
    end
  end
end
