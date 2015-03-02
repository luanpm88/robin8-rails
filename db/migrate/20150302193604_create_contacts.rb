class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :author_id
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :twitter_screen_name

      t.timestamps null: false
    end
  end
end
