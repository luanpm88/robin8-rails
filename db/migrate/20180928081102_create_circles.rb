class CreateCircles < ActiveRecord::Migration
  def change
    create_table :circles do |t|
      t.string :name
      t.string :label
      t.string :color
      t.integer :position
      t.timestamps null: false
    end
  end
end
