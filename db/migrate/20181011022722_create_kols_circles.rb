class CreateKolsCircles < ActiveRecord::Migration
  def change
    create_table :kols_circles do |t|
      t.belongs_to :kol
      t.belongs_to :circle
      t.timestamps null: false
    end
  end
end
