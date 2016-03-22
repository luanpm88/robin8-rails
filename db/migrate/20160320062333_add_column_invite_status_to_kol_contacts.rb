class AddColumnInviteStatusToKolContacts < ActiveRecord::Migration
  def change
    add_column :kol_contacts, :invite_status, :boolean, :default => false
    add_column :kol_contacts, :invite_at, :datetime

    add_column :tmp_kol_contacts, :invite_status, :boolean, :default => false
    add_column :tmp_kol_contacts, :invite_at, :datetime
  end
end
