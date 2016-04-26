class AddColumnScoreItemToKolInfluenceValues < ActiveRecord::Migration
  def change
    add_column :kol_influence_values, :base_score, :integer, :default => 500
    add_column :kol_influence_values, :follower_score, :integer, :default => 0
    add_column :kol_influence_values, :status_score, :integer, :default => 0
    add_column :kol_influence_values, :register_score, :integer, :default => 0
    add_column :kol_influence_values, :verify_score, :integer, :default => 0

    add_column :kol_influence_values, :campaign_total_click_score, :integer, :default => 0
    add_column :kol_influence_values, :campaign_avg_click_score, :integer, :default => 0

    add_column :kol_influence_values, :article_total_click_score, :integer, :default => 0
    add_column :kol_influence_values, :article_avg_click_score, :integer, :default => 0
  end
end
