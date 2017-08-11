class CreateInfluenceIndustries < ActiveRecord::Migration
  def change
    create_table :influence_industries do |t|
      t.integer :influence_metric_id
      t.string :industry_name
      t.float :industry_score
      t.float :avg_posts
      t.float :avg_comments
      t.float :avg_likes

      t.timestamps null: false
    end
    add_index :influence_industries, :influence_metric_id
  end
end
