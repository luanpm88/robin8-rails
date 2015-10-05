class AddUnsubscribeTokenToPitchContacts < ActiveRecord::Migration
  def change
    add_column :pitches_contacts, :unsubscribe_token, :string
  end
end
