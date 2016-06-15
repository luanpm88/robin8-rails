class CreateUserSignInRecords < ActiveRecord::Migration
  def change
    create_table :user_sign_in_records do |t|
      t.string :sign_in_token
      t.string :user_id      
      t.timestamps null: false
    end
  end
end
