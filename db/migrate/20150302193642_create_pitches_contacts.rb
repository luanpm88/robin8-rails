class CreatePitchesContacts < ActiveRecord::Migration
  def change
    create_table :pitches_contacts do |t|
      t.integer :pitch_id
      t.integer :contact_id

      t.timestamps null: false
    end
  end
end
