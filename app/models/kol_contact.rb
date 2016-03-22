class KolContact < ActiveRecord::Base
  scope :order_by_exist, ->{ order('exist desc, influence_score desc')}
  scope :joined, -> {where(:exist => true)}
  scope :unjoined, -> {where(:exist => false)}
end
