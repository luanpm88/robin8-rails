class Creation < ActiveRecord::Base
  has_many :creation_targets
  belongs_to :user
end
