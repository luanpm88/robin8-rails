class CreateElasticArticleActions < ActiveRecord::Migration
  def change
    create_table :elastic_article_actions do |t|
    	t.string :_action, null: false
    	t.string :post_id, null: false

    	t.references :kol

      t.timestamps null: false
    end
  end
end
