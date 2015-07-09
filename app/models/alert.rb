class Alert < ActiveRecord::Base
  belongs_to :stream
  
  validates_presence_of :stream_id
  validate :should_email_or_phone_be_present
  validates :email, email_format: true, allow_blank: true
  validates :phone, phone: true, allow_blank: true
  validates :enabled, :inclusion => {:in => [true, false]}
  
  private
  
  def should_email_or_phone_be_present
    if phone.blank? && email.blank?
      self.errors.add :email_and_phone, "should be present, both can't be blank."
    end
  end
end
