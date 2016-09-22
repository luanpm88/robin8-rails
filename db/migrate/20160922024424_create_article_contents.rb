class CreateArticleContents < ActiveRecord::Migration
  def change
    create_table :article_contents do |t|
      t.integer    :article_category_id
      t.string     :title
      t.string     :cover
      t.text       :content
      t.string     :url

      t.boolean    :is_sync, :default => false


      t.timestamps null: false
    end
  end
end
