class CreateCarticles < ActiveRecord::Migration
  def change
    create_table   :carticles do |t|
      t.references :kol_id
      t.text       :body
      t.timestamps null: false
    end
  end
end