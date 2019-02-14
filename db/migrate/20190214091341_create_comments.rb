class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :resource_id
      t.string  :resource_type
      t.integer :resource_from_id
      t.string  :resource_from_type
      t.integer :resource_to_id
      t.string  :resource_to_type
      t.integer :parent_id
      t.text    :content
      t.integer :score
      t.timestamps null: false
    end
  end
end
