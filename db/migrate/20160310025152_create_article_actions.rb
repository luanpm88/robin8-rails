class CreateArticleActions < ActiveRecord::Migration
  def change
    create_table :article_actions do |t|
      t.integer :kol_id
      t.string :article_id
      t.string :article_url
      t.string :article_avatar_url
      t.string :article_author
      t.string :action

      t.timestamps null: false
    end
  end
end
