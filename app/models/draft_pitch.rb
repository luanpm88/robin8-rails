class DraftPitch < ActiveRecord::Base
  belongs_to :release
  has_many :test_emails
end
