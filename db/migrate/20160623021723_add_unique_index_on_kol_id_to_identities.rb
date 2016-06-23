class AddUniqueIndexOnKolIdToIdentities < ActiveRecord::Migration
  def change
    add_index :identities, [:kol_id, :uid], :unique => true
    add_index :tmp_identities, [:kol_uuiid, :uid], :unique => true
  end
end
