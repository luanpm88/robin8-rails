class Contact < ActiveRecord::Base
  has_many :media_lists_contacts
  has_many :media_lists, through: :media_lists_contacts
  has_many :pitches_contacts
  has_many :pitches, through: :pitches_contacts
  
  validates :email, email_format: true, allow_blank: true
end
