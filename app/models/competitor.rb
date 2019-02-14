#竞争对手
class Competitor < ActiveRecord::Base
  default_scope ->{where(status: 1)}
end
