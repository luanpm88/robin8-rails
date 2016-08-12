class CreateKolAnnouncements < ActiveRecord::Migration
  def change
    create_table :kol_announcements do |t|
      t.integer :position
      t.string  :category
      t.string :cover
      t.string :title
      t.string :link
      t.string :kol_id
      t.boolean :enable, :default => true

      t.timestamps null: false
    end
  end
end
