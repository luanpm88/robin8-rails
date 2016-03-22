class CreateKolContacts < ActiveRecord::Migration
  def change
    create_table :kol_contacts do |t|
      t.integer :kol_id
      t.string :name
      t.string :mobile
      t.boolean :exist, :default => false
      t.string :city
      t.float :score

      t.timestamps null: false
    end
  end
end
