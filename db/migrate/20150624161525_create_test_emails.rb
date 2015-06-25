class CreateTestEmails < ActiveRecord::Migration
  def change
    create_table :test_emails do |t|
      t.integer :draft_pitch_id
      t.string :emails

      t.timestamps null: false
    end
  end
end
