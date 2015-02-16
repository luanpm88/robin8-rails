class CreateStreams < ActiveRecord::Migration
  def change
    create_table :streams do |t|
      t.integer :user_id, null: false
      t.index :user_id
      t.string :name
      t.string :topics
      t.string :sources

      t.timestamps null: false
    end
  end
end
