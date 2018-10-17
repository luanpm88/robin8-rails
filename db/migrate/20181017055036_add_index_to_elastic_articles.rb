class AddIndexToElasticArticles < ActiveRecord::Migration
  def change
  	add_index :elastic_articles, :post_id
  end
end
