class AddSentToPitchesContacts < ActiveRecord::Migration
  def change
    add_column :pitches_contacts, :sent, :boolean, default: false
  end
end
