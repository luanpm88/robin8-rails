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
  validates_uniqueness_of :author_id, allow_nil: true, 
    conditions: -> { where(origin: 0) }
  validates_uniqueness_of :twitter_screen_name, allow_nil: true,
    conditions: -> { where(origin: 1) }
  validates_uniqueness_of :email, allow_nil: true, 
    conditions: -> { where(origin: 2) }
  
  def self.bulk_find_or_create(contacts_param)
    contacts_param.map do |contact|
      case contact['origin']
      when 'pressr'
        self.find_or_create_by!(author_id: contact['author_id']) do |c|
          c.first_name = contact['first_name']
          c.last_name = contact['last_name']
          c.email = contact['email']
          c.origin = 0
        end
      when 'twtrland'
        self.find_or_create_by!(twitter_screen_name: contact['twitter_screen_name']) do |c|
          c.first_name = contact['first_name']
          c.last_name = contact['last_name']
          c.origin = 1
        end
      when 'media_list'
        self.find(contact['contact_id'])
      else
        nil
      end
    end
  end
end
