class TestEmail < ActiveRecord::Base
  belongs_to :draft_pitch
  
  validates_presence_of :emails, :draft_pitch
  validate :check_email_addresses

  private
  
  def check_email_addresses
    emails.split(/,\s*/).each do |email| 
      unless email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
        errors.add(:emails, "are invalid due to #{email}")
      end
    end
  end
end
