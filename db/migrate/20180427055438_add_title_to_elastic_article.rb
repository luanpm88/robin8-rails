class AddTitleToElasticArticle < ActiveRecord::Migration
  def change
  	add_column :elastic_articles, :title, :string
  end
end
