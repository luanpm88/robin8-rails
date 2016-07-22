class CreateKolProfessions < ActiveRecord::Migration
  def change
    create_table :kol_professions do |t|
      t.integer :kol_id
      t.integer :profession_id

      t.timestamps null: false
    end
  end
end
