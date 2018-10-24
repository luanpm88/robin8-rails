class CreateCreatorsCities < ActiveRecord::Migration
  def change
    create_table :creators_cities do |t|
      t.belongs_to :creator
      t.belongs_to :city
      t.timestamps null: false
    end
  end
end
