class Feature < ActiveRecord::Base
  validates :name,:presence => true
  validates :name,:slug,:uniqueness => true

end