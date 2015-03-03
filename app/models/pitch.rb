class Pitch < ActiveRecord::Base
  has_many :pitches_contacts
  has_many :contacts, through: :pitches_contacts
  belongs_to :user
  belongs_to :release
  
  validates :email_address, email_format: true, allow_blank: true
  validates_length_of :email_address, maximum: 255
  validates_length_of :email_subject, maximum: 2500
  validates_numericality_of :summary_length, 
    greater_than_or_equal_to: 0, less_than_or_equal_to: 10
end
