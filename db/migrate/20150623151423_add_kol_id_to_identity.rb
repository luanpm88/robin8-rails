class AddKolIdToIdentity < ActiveRecord::Migration
  def change
    add_column :identities, :kol_id, :integer
  end
end
