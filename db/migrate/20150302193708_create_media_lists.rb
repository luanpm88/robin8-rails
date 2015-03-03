class CreateMediaLists < ActiveRecord::Migration
  def change
    create_table :media_lists do |t|
      t.string :name
      t.integer :user_id, null: false

      t.timestamps null: false
    end
  end
end
