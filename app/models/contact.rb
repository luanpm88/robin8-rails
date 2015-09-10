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
  validates_uniqueness_of :author_id, scope: :origin,
    conditions: -> { where(origin: 0) }, allow_nil: true
  validates_uniqueness_of :twitter_screen_name, scope: :origin,
    conditions: -> { where(origin: 1) }, allow_nil: true
  validates_uniqueness_of :email, scope: :origin,
    conditions: -> { where(origin: 2) }, allow_nil: true

  def self.bulk_find_or_create(contacts_param)
    res = contacts_param.map do |contact|
      case contact['origin']
        when 'pressr'
          if !contact['email'].blank?
            if contact['need_approve']
              EmailApprove.find_or_create_by!(author_id: contact['author_id']) do |c|
                c.first_name = contact['first_name']
                c.last_name = contact['last_name']
                c.email = contact['email']
                c.outlet = contact['outlet']
              end
            end
            self.find_or_create_by!(author_id: contact['author_id']) do |c|
              c.first_name = contact['first_name']
              c.last_name = contact['last_name']
              c.email = contact['email']
              c.outlet = contact['outlet']
              c.origin = 0
            end
          end
      when 'twtrland'
        self.find_or_create_by!(twitter_screen_name: contact['twitter_screen_name']) do |c|
          c.first_name = contact['first_name']
          c.last_name = contact['last_name']
          c.outlet = 'Twitter'
          c.origin = 1
        end
      when 'media_list'
        self.find(contact['contact_id'])
      else
        nil
      end
    end
    res.select {|x| not x.blank?}
  end

  def full_name
    if !first_name.blank? && !last_name.blank?
      "#{first_name} #{last_name}"
    elsif !first_name.blank?
      first_name
    elsif !last_name.blank?
      last_name
    else
      "N/A"
    end
  end
end
