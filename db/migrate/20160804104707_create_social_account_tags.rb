class CreateSocialAccountTags < ActiveRecord::Migration
  def change
    create_table :social_account_tags do |t|
      t.integer :social_account_id
      t.integer :tag_id
      t.timestamps null: false
    end

    add_index :social_account_tags, :social_account_id
    add_index :social_account_tags, :tag_id
  end
end
