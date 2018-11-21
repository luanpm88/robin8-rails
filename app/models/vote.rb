class Vote < ActiveRecord::Base
	
	belongs_to :kol

	after_create :counter_attrs

	def counter_attrs
		kol.redis_votes_count.increment
	end

end
