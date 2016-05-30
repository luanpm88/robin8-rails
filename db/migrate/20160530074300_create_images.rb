class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.integer :referable_id
      t.string :referable_type
      t.string :avatar

      t.timestamps null: false
    end
  end
end
