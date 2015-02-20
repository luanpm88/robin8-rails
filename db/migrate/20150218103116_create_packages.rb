class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :slug
      t.boolean :is_active
      t.float :price
      t.string :status
      t.integer :interval

      t.timestamps null: false
    end
  end
end
