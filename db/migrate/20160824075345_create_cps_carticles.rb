class CreateCpsCarticles < ActiveRecord::Migration
  def change
    create_table   :cps_carticles do |t|
      t.references :kol_id
      t.text       :body
      t.timestamps null: false
    end
  end
end
