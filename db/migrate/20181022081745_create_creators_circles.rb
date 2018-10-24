class CreateCreatorsCircles < ActiveRecord::Migration
  def change
    create_table :creators_circles do |t|
      t.belongs_to :creator
      t.belongs_to :circle
      t.timestamps null: false
    end
  end
end
