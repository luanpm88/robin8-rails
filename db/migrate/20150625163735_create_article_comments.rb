class CreateArticleComments < ActiveRecord::Migration
  def change
    create_table :article_comments do |t|
      t.text :text
      t.string :type
      t.datetime :sent_at
      t.references :sender, polymorphic: true, index: true
      t.belongs_to :articles, index: true
      t.timestamps null: false
    end
  end
end
