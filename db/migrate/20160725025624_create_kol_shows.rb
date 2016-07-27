class CreateKolShows < ActiveRecord::Migration
  def change
    create_table :kol_shows do |t|
      t.integer :kol_id
      t.string :title
      t.text :desc
      t.string :link
      t.string :provider

      t.timestamps null: false
    end
  end
end
