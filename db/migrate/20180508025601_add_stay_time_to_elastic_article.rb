class AddStayTimeToElasticArticle < ActiveRecord::Migration
  def change
  	add_column :elastic_articles, :stay_time, :integer, default: 0
  end
end
