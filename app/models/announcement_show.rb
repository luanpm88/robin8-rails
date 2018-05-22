class AnnouncementShow < ActiveRecord::Base

	belongs_to :kol
	belongs_to :announcement
end
