class CreateKolProfessions < ActiveRecord::Migration
  def change
    create_table :kol_professions do |t|
      t.integer :kol_id
      t.integer :profession_id

      t.timestamps null: false
    end

    add_index :kol_professions, :kol_id
    add_index :kol_professions, :profession_id
  end
end
