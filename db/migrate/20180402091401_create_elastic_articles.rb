class CreateElasticArticles < ActiveRecord::Migration
  def change
    create_table :elastic_articles do |t|
    	t.string :post_id, null: false

    	t.integer :reads_count, default: 0
    	t.integer :likes_count, default: 0
    	t.integer :collects_count, default: 0
    	t.integer :forwards_count, default: 0

    	t.references :tag

      t.timestamps null: false
    end
  end
end
