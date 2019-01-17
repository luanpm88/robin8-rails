class Trademark < ActiveRecord::Base

	belongs_to :user
	has_many :creations
	
end
