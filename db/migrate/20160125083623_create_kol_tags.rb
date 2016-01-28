class CreateKolTags < ActiveRecord::Migration
  def change
    create_table :kol_tags do |t|
      t.integer :kol_id
      t.integer :tag_id

      t.timestamps null: false
    end
  end
end
