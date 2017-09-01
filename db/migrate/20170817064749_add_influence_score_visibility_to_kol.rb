class AddInfluenceScoreVisibilityToKol < ActiveRecord::Migration
  def change
    add_column :kols, :influence_score_visibility, :boolean, default: true
  end
end
