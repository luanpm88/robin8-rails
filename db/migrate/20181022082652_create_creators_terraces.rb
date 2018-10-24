class CreateCreatorsTerraces < ActiveRecord::Migration
  def change
    create_table :creators_terraces do |t|
      t.belongs_to :creator
      t.belongs_to :terrace
      t.timestamps null: false
    end
  end
end
