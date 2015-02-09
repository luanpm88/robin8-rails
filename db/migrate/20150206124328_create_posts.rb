class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.text :text
      t.integer :user_id
      t.datetime :scheduled_date

      t.timestamps null: false
    end

    add_index :posts, :user_id
  end
end
