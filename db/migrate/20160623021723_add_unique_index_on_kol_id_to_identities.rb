class AddUniqueIndexOnKolIdToIdentities < ActiveRecord::Migration
  def change
    # change_column :identities, :uid, :string, :limit => 50
    # change_column :tmp_identities, :kol_uuid, :string, :limit => 50
    # change_column :tmp_identities, :uid, :string, :limit => 50
    #
    # add_index :identities, [:kol_id, :uid], :unique => true
    add_index :tmp_identities, [:kol_uuid, :uid], :unique => true
  end
end
