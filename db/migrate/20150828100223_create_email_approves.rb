class CreateEmailApproves < ActiveRecord::Migration
  def change
    create_table :email_approves do |t|
      t.integer :author_id
      t.string :first_name
      t.string :last_name
      t.string :outlet
      t.string :email

      t.timestamps null: false
    end
  end
end
