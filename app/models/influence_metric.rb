class InfluenceMetric < ActiveRecord::Base

  has_many :influence_industries
  belongs_to :kol

  validates_presence_of :provider, :influence_score, :avg_posts, :avg_comments, :avg_likes

  def create_or_update_industries industries_params
    self.influence_industries.delete_all if self.influence_industries.any?
    industries_params.each do |industry|
      industry = industry.merge(influence_metric_id: self.id)
      InfluenceIndustry.create_from_params industry
    end
  end

  def influence_level
    case self.influence_score
      when 0..300
        '影响力较差'
      when 301..600
        '影响力中等'
      when 601..800
        '影响力良好'
      when 801..900
        '影响力优秀'
      when 901..1000
        '影响力极好'
      else
        '影响力未知'
    end
  end

  def influence_score_percentile
    total_influence_scores = InfluenceMetric.all.count
    users_less_than_current_kol = InfluenceMetric.all.where("influence_score < ?", self.influence_score).count
    users_less_percentile = (users_less_than_current_kol * 1.0 / total_influence_scores * 100).to_i
    return "超过#{users_less_percentile}%的用户"
  end

end
