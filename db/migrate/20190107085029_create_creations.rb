class CreateCreations < ActiveRecord::Migration
  def change
    create_table :creations do |t|
      t.string :name
      t.text :description
      t.integer :terrace_id
      t.string :terrace_name
      t.string :image
      t.text :required
      t.datetime :start_time
      t.datetime :end_time
      t.integer :kol_number
      t.float :budget, default: 0.0
      t.text :notice
      t.timestamps null: false
    end
  end
end
