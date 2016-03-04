class CreateTmpKolContacts < ActiveRecord::Migration
  def change
    create_table :tmp_kol_contacts do |t|
        t.integer :kol_id
        t.string :name
        t.string :mobile
        t.string :city
        t.boolean :exist, :default => false
        t.float :score
        t.string :kol_uuid

        t.timestamps null: false
    end
  end
end
