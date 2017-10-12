class KolPk < ActiveRecord::Base
  belongs_to :challenger, class_name: "Kol", inverse_of: :received_challenges
  belongs_to :challengee, class_name: "Kol", inverse_of: :sent_challenges

  validates_presence_of :challenger_id, :challengee_id, :challenger_score,
    :challengee_score, :first_industry, :first_score, :second_industry,
    :second_score, :third_industry, :third_score

  default_scope { order(id: :desc) }

  def the_other(kol)
    return challengee if kol == challenger
    return challenger if kol == challengee
  end

  def score_for(kol)
    return challenger_score if kol == challenger
    return challengee_score if kol == challengee
  end

  def result_for(kol)
    return 'tied' if winner.nil?
    return kol == winner ? 'win':'lost'
  end

  def winner
    return challenger if challenger_score > challengee_score
    return challengee if challenger_score < challengee_score
  end
end
