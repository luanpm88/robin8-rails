class Followship < ActiveRecord::Base
  belongs_to :follower, :class_name => 'Kol'
  belongs_to :kol
end
