class SyncInfluenceScoreToKol < ActiveRecord::Migration
  def change
    KolInfluenceValue.all.each do |value|
      value.kol.update_column(:influence_score, value.influence_score)       if value.kol
    end
  end
end

