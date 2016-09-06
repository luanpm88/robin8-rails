class CreateCrmSellers < ActiveRecord::Migration
  def change
    create_table :crm_sellers do |t|
      t.string :mobile_number
      t.string :password_digest
      t.string :name
      t.string :department
      t.string :avatar
      t.string :invite_code
      t.string :private_token

      t.timestamps null: false
    end
  end
end
