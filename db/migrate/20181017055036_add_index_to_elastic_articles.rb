class AddIndexToElasticArticles < ActiveRecord::Migration
  def change
  	add_index :elastic_articles, [:post_id], name: :index_elastic_articles_post
  end
end
