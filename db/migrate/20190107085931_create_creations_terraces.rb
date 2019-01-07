class CreateCreationsTerraces < ActiveRecord::Migration
  def change
    create_table :creations_terraces do |t|
      t.integer :creation_id
      t.integer :terrace_id
      t.integer :exposure_value
      t.timestamps null: false
    end
  end
end
