class CreatePitches < ActiveRecord::Migration
  def change
    create_table :pitches do |t|
      t.integer :user_id, null: false
      t.boolean :sent, default: false
      t.text :twitter_pitch
      t.text :email_pitch
      t.integer :summary_length, default: 5
      t.string :email_address

      t.timestamps null: false
    end
  end
end
