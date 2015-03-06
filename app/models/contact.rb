class Contact < ActiveRecord::Base
  ORIGIN_TYPES = {
    0 => :pressr,
    1 => :twtrland,
    2 => :media_list
  }
  
  has_many :media_lists_contacts
  has_many :media_lists, through: :media_lists_contacts
  has_many :pitches_contacts
  has_many :pitches, through: :pitches_contacts
  
  validates :email, email_format: true, allow_blank: true
  validates_uniqueness_of :author_id, conditions: -> { where(origin: 0) }
  validates_uniqueness_of :twitter_screen_name, conditions: -> { where(origin: 1) }
  validates_uniqueness_of :email, conditions: -> { where(origin: 2) }
end
