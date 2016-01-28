class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :name
      t.string :label
      t.integer :position

      t.timestamps null: false
    end
  end
end
