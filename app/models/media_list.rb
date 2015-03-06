class MediaList < ActiveRecord::Base
  has_many :contacts, through: :media_lists_contacts
  has_many :media_lists_contacts
  belongs_to :user
  
  has_attached_file :attachment
  
  validates_attachment_presence :attachment
  validates_attachment_content_type :attachment, :content_type => 'text/csv'
  validates_attachment_size :attachment, :in => 0..2.kilobytes
  validates_uniqueness_of :name
  
  before_save :import_contacts
    
  private
  
  def import_contacts
    path = attachment.queued_for_write[:original].path
    contacts = CSV.read(path)
    self.contacts << contacts.inject([]) do |memo, contact|
      if (contact.size != 3) || contact[0].blank? || contact[1].blank? || contact[2].blank?
        errors.add(:CSV, " format is not valid")
        return false
      end
      
      unless validate_url(contact[2])
        errors.add(:email, "format in CSV file is not valid")
        return false
      end
      
      begin
        memo << Contact.find_or_create_by(email: contact[2]) do |c|
          c.first_name = contact[0]
          c.last_name  = contact[1]
          c.origin     = 2
        end
      rescue ActiveRecord::RecordNotUnique
        retry
      end
      memo
    end
  end
  
  def validate_url(url)
    unless url =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      false
    else
      true
    end
  end
end
