#代理的品牌
class Trademark < ActiveRecord::Base
  STATUS = {
    0 => '不显示',
    1 => '显示',
    -1 => '删除'
  }
  
	belongs_to :user
	has_many :creations

  default_scope ->{where(status: 1)}
end
