class Vote < ActiveRecord::Base

	WaitTime = Rails.env.production? ? 24.hours : 5.minutes

	belongs_to :kol
	belongs_to :tender, class_name: Kol, foreign_key: :tender_id

	before_create :init_attrs
	after_create :counter_attrs

	def init_attrs
		self.date_show = Time.now.strftime('%F')
	end

	def counter_attrs
		kol.redis_votes_count.increment

    $redis.setex("#{tender.mobile_number}_vote_kol_#{kol.id}", WaitTime, '1')
	end

end
