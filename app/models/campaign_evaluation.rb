class CampaignEvaluation < ActiveRecord::Base

  Items = ['effect', 'experience', 'review']

  def self.evaluate(campaign, effect_score, experience_score, review_content)
    campaign.build_effect_evaluation(score: effect_score)
    campaign.build_experience_evaluation(score: experience_score)
    campaign.build_review_evaluation(content: review_content)
    campaign.evaluation_status = 'evaluated'
    campaign.save
  end

end
