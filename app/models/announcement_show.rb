class AnnouncementShow < ActiveRecord::Base

	belongs_to :kol
	belongs_to :announcement

	after_create :counter_add

	def counter_add
		# kol.redis_announcement_clicks_count.increment
    announcement.redis_clicks_count.increment
	end
	
end
