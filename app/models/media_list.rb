class MediaList < ActiveRecord::Base
  has_many :contacts, through: :media_lists_contacts
  has_many :media_lists_contacts
  belongs_to :user
  
  validates_presence_of :name
end
