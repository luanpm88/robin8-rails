class MediaList < ActiveRecord::Base
  has_many :contacts, through: :media_lists_contacts
  has_many :media_lists_contacts
  belongs_to :user
  
  has_attached_file :attachment
  
  validates_attachment_content_type :attachment, :content_type => 'text/csv'
  validates_attachment_size :attachment, :in => 0..500.kilobytes
  validates_presence_of :name
  validates_uniqueness_of :name
  validates :contacts, association_count: { minimum: 1 }
    
  before_save :import_contacts, if: :attachment?
    
  private
  
  def import_contacts
    path = attachment.queued_for_write[:original].path
    contacts = CSV.read(path)
    self.contacts << contacts.inject([]) do |memo, contact|
      if (contact.size == 3) && !contact[0].blank? && 
        !contact[1].blank? && !contact[2].blank? && validate_email(contact[2])
        
        begin
          memo << Contact.find_or_create_by(email: contact[2]) do |c|
            c.first_name = contact[0]
            c.last_name  = contact[1]
            c.outlet = 'Media List'
            c.origin     = 2
          end
        rescue ActiveRecord::RecordNotUnique
          retry
        end
      end
      
      memo
    end
  end
  
  def attachment?
    if attachment.blank? || 
      (attachment.queued_for_write[:original] == '/attachments/original/missing.png')
      false
    else
      true
    end
  end
  
  def validate_email(url)
    unless url =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      false
    else
      true
    end
  end
end
