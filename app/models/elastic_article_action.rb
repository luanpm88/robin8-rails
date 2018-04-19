class ElasticArticleAction < ActiveRecord::Base

	ACTIONS = %w(like collect forward read)

	validates_inclusion_of :_action, in: ACTIONS

	belongs_to :kol

	scope :likes, 		->{ where(_action: 'like') }
	scope :collects, 	->{ where(_action: 'collect') }
	scope :forwards,	->{ where(_action: 'forward') }
	scope :reads, 		->{ where(_action: 'read') }
end
