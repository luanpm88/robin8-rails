class Pitch < ActiveRecord::Base
  has_many :pitches_contacts
  has_many :contacts, through: :pitches_contacts
  belongs_to :user
  
  validates :email, email_format: true, allow_blank: true
end
