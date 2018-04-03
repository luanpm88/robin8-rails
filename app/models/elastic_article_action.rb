class ElasticArticleAction < ActiveRecord::Base

	ACTIONS = %w(like collect)

	validates_inclusion_of :_action, in: ACTIONS

	belongs_to :kol

	scope :likes, 		->{ where(_action: 'like') }
	scope :collects, 	->{ where(_action: 'collect') }
end
