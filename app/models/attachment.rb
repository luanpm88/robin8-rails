class Attachment < ActiveRecord::Base
  VALID_TYPES = ['image', 'file', 'video']
  belongs_to :imageable, polymorphic: true
  validates_inclusion_of :attachment_type, in: VALID_TYPES
end