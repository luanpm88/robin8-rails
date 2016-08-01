class CreateKolKeywords < ActiveRecord::Migration
  def change
    create_table :kol_keywords do |t|
      t.integer :kol_id
      t.integer :social_account_id
      t.string :keyword
      t.string :weight
      t.timestamps null: false
    end

    add_index :kol_keywords, :kol_id
    add_index :kol_keywords, :social_account_id
  end
end
