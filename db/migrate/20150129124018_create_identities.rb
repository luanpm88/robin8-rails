class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :token
      t.string :token_secret
      t.string :name

      t.timestamps null: false
    end
  end
end
