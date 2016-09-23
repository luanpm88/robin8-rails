class CreateArticleCategories < ActiveRecord::Migration
  def change
    create_table :article_categories do |t|
      t.string :name
      t.string :url
      t.string :sub_name
      t.string :sub_url

      t.timestamps null: false
    end
  end
end
