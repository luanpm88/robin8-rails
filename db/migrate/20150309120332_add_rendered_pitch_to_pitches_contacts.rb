class AddRenderedPitchToPitchesContacts < ActiveRecord::Migration
  def change
    add_column :pitches_contacts, :rendered_pitch, :text
  end
end
