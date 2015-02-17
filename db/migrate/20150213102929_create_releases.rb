class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.string :title
      t.text :text
      t.integer :newsroom_id

      t.timestamps null: false
    end
  end
end
