class CreateDraftPitches < ActiveRecord::Migration
  def change
    create_table :draft_pitches do |t|
      t.text :twitter_pitch
      t.text :email_pitch
      t.integer :summary_length, limit: 1
      t.string :email_address
      t.integer :release_id
      t.string :email_subject, limit: 2500

      t.timestamps null: false
    end
    
    add_index :draft_pitches, :release_id
  end
end
