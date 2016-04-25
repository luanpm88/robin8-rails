class AddIndexToKolContacts < ActiveRecord::Migration
  def change
    change_column :kol_contacts, :mobile, :string, :limit => 20
    change_column :tmp_kol_contacts, :mobile,:string, :limit => 20

    add_index :kol_contacts, :kol_id
    add_index :kol_contacts, :mobile

    add_index :tmp_kol_contacts, :kol_id
    add_index :tmp_kol_contacts, :mobile
  end
end
