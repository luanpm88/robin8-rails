class AddIndexToElasticArticles < ActiveRecord::Migration
  def change
  	add_index :elastic_articles, [:post_id], name: :index_eas_on_post_id
  end
end
