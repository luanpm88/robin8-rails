class CreateInfluenceMetrics < ActiveRecord::Migration
  def change
    create_table :influence_metrics do |t|
      t.boolean :calculated, default: false
      t.string :provider
      t.float :influence_score
      t.integer :influence_level
      t.integer :influence_score_percentile
      t.date :calculated_date
      t.float :avg_posts
      t.float :avg_comments
      t.float :avg_likes

      t.integer :kol_id

      t.timestamps null: false
    end

    add_index :influence_metrics, :kol_id
  end
end
