class CreateArticleContents < ActiveRecord::Migration
  def change
    create_table :article_contents do |t|
      t.string :url
      t.integer    :article_category_id
      t.string     :title
      t.string     :cover
      t.text       :content


      t.timestamps null: false
    end
  end
end
