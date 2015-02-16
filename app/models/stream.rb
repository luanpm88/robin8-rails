class Stream < ActiveRecord::Base
  belongs_to :user
  serialize :topics, Array
  serialize :sources, Array
end
