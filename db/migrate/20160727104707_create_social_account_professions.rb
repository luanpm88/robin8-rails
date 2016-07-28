class CreateSocialAccountProfessions < ActiveRecord::Migration
  def change
    create_table :social_account_professions do |t|
      t.integer :social_account_id
      t.integer :profession_id
      t.timestamps null: false
    end

    add_index :social_account_professions, :social_account_id
    add_index :social_account_professions, :profession_id
  end
end
