class CreateUnsubscribeEmails < ActiveRecord::Migration
  def change
    create_table :unsubscribe_emails do |t|
      t.integer :user_id
      t.string :email

      t.timestamps null: false
    end
    add_index :unsubscribe_emails, :user_id
    add_index :unsubscribe_emails, :email
  end
end
