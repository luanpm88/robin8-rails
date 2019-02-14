#代理的品牌
class Trademark < ActiveRecord::Base
	belongs_to :user
	has_many :creations

  default_scope ->{where(status: 1)}
end
