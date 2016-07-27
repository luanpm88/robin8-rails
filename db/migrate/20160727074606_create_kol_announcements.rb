class CreateKolAnnouncements < ActiveRecord::Migration
  def change
    create_table :kol_announcements do |t|
      t.string  :category
      t.string :cover
      t.string :title
      t.string :link
      t.string :kol_id

      t.timestamps null: false
    end
  end
end
