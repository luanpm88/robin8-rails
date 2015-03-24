class AddOn < ActiveRecord::Base
  validates :name,:price,:presence => true
end