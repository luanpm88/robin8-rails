#竞争对手
class Competitor < ActiveRecord::Base
  STATUS = {
    0 => '不显示',
    1 => '显示',
    -1 => '删除'
  }
<<<<<<< HEAD
  
  default_scope ->{where.not(status: -1)}
=======

  validates :status, :inclusion => { :in => [1, 0, -1] }

  default_scope ->{where(status: 1)}


>>>>>>> 531a36354da66949fe90943f455954f5cdf5661b
end
