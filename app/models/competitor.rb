#竞争对手
class Competitor < ActiveRecord::Base
  STATUS = {
    0 => '不显示',
    1 => '显示',
    -1 => '删除'
  }
  
  default_scope ->{where.not(status: -1)}
end
