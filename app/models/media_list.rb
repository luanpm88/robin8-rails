class MediaList < ActiveRecord::Base
  has_many :contacts, through: :media_lists_contacts
  has_many :media_lists_contacts
  belongs_to :user
  
  has_attached_file :attachment
  
  validates_attachment_content_type :attachment, :content_type => 'text/csv'
  validates_attachment_size :attachment, :in => 0..2.megabytes
  validates_presence_of :name
  validates_uniqueness_of :name
    
  before_save :import_contacts, if: :attachment?
    
  private
  
  def import_contacts
    path = attachment.queued_for_write[:original].path
    contacts = CSV.read(path)
    self.contacts << contacts.inject([]) do |memo, contact|
      
      contact.reject! {|c| c.nil?}
      
      if (contact.size == 4) && !contact[0].strip.blank? && 
        !contact[1].strip.blank? && !contact[2].strip.blank? && 
        !contact[3].strip.blank? && validate_email(contact[2].strip)
        
        new_contact = Contact.where(email: contact[2].strip).first
        
        memo << if new_contact.nil?
          Contact.create(email: contact[2].strip,
            first_name: contact[0].strip,
            last_name: contact[1].strip,
            outlet: contact[3].strip,
            origin: 2)
        else
          new_contact.update(first_name: contact[0].strip,
            last_name: contact[1].strip,
            outlet: contact[3].strip)
          
          new_contact
        end
      end
      
      memo
    end
    
    if self.contacts.size == 0
      self.errors.add(:uploaded_file, "must have exactly <strong>four</strong> columns, formatted as <strong>first name, last name, email address, outlet</strong>")
      return false
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
