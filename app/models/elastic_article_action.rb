class ElasticArticleAction < ActiveRecord::Base

	ACTIONS = %w(like collect forward)

	validates_inclusion_of :_action, in: ACTIONS

	belongs_to :kol

	scope :likes, 		->{ where(_action: 'like') }
	scope :collects, 	->{ where(_action: 'collect') }
	scope :forwards,	->{ where(_action: 'forwards') }
end
