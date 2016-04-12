class CreateKolInfluenceValueHistories < ActiveRecord::Migration
  def change
    create_table :kol_influence_value_histories do |t|
      t.integer :kol_id
      t.string :kol_uuid
      t.string :name
      t.string :avatar_url
      t.string :influence_score
      t.string :influence_level

      t.integer :location_score
      t.integer :mobile_model_score
      t.integer :identity_score
      t.integer :identity_count_score
      t.integer :contact_score

      t.integer :base_score, :integer, :default => 500
      t.integer :follower_score, :integer, :default => 0
      t.integer :status_score, :integer, :default => 0
      t.integer :register_score, :integer, :default => 0
      t.integer :verify_score, :integer, :default => 0

      t.integer :campaign_total_click_score, :default => 0
      t.integer :campaign_avg_click_score, :default => 0

      t.integer :article_total_click_score, :default => 0
      t.integer :article_avg_click_score, :default => 0

      t.boolean :is_auto, :default => false

      t.timestamps null: false
    end
  end
end
