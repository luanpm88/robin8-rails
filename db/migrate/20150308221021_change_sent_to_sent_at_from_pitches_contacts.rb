class ChangeSentToSentAtFromPitchesContacts < ActiveRecord::Migration
  def change
    remove_column :pitches_contacts, :sent
    add_column :pitches_contacts, :sent_at, :datetime, default: nil
  end
end
