class Feature < ActiveRecord::Base
  validates :name,:presence => true
  validates :name,:slug,:uniqueness => true

  has_many :user_features

end