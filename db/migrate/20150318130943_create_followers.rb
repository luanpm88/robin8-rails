class CreateFollowers < ActiveRecord::Migration
  def change
    create_table :followers do |t|
      t.string :email
      t.string :list_type
      t.integer :news_room_id

      t.timestamps null: false
    end
    add_index :followers, :news_room_id
  end
end
