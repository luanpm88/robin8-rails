class Pitch < ActiveRecord::Base
  has_many :pitches_contacts
  has_many :contacts, through: :pitches_contacts
  belongs_to :user
  belongs_to :release
  
  validates_inclusion_of :email_targets, :twitter_targets, in: [true, false]
  validates_presence_of :user_id
  validates_presence_of :release_id
  validates_numericality_of :release_id
  validates :email_address, email_format: true, allow_blank: true
  validates_length_of :email_address, maximum: 255
  validates_length_of :email_subject, maximum: 2500
  validates_numericality_of :summary_length, 
    greater_than_or_equal_to: 1, less_than_or_equal_to: 10
  validates_presence_of :twitter_pitch, if: :twitter_targets?
  validates_presence_of :email_pitch, :email_subject, 
    :email_address, if: :email_targets?
    
  private
  
  def email_targets?
    email_targets
  end
  
  def twitter_targets?
    twitter_targets
  end
end
