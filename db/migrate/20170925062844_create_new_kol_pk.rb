class CreateNewKolPk < ActiveRecord::Migration
  def change
    create_table :kol_pks do |t|
      t.integer :challenger_id
      t.integer :challengee_id
      t.integer :challenger_score
      t.integer :challengee_score
      t.string  :first_industry
      t.string  :second_industry
      t.string  :third_industry
      t.integer :first_score
      t.integer :second_score
      t.integer :third_score
      t.timestamps
    end
    add_index :kol_pks, :challenger_id
    add_index :kol_pks, :challengee_id
    add_index :kol_pks, :id
  end
end
