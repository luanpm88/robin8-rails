class Admintag < ActiveRecord::Base

  # Admin tags
  has_and_belongs_to_many :kols

  has_one :admintag_strategy

end
