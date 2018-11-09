class CreateTerraces < ActiveRecord::Migration
  def change
    create_table :terraces do |t|
      t.string :name
      t.string :avatar
      t.string :address
      t.string :short_name
      t.timestamps null: false
    end
  end
end
