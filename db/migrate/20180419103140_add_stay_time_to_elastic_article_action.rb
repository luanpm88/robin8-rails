class AddStayTimeToElasticArticleAction < ActiveRecord::Migration
  def change
  	add_column :elastic_article_actions, :stay_time, :integer, default: nil
  end
end
