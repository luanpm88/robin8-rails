#代理的品牌
class Trademark < ActiveRecord::Base
  STATUS = {
    0 => '不显示',
    1 => '显示',
    -1 => '删除'
  }

  validates :status, :inclusion => { :in => [1, 0, -1] }
  
	belongs_to :user
	has_many :creations

  scope :active, ->{where.not(status: -1).order(updated_at: :desc)}
end
