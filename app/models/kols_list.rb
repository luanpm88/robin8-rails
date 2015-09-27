class KolsList < ActiveRecord::Base
  has_many :kols_lists_contacts
  belongs_to :user
end

