class Attachment < ActiveRecord::Base
  VALID_TYPES = ['image', 'file', 'video']
  belongs_to :imageable, polymorphic: true
  validates_inclusion_of :attachment_type, in: VALID_TYPES

  after_create do |attachment|
    AmazonStorageWorker.perform_async("attachment", attachment.id, attachment.url, nil, :url)
  end

  after_destroy do |attachment|
    AmazonDeleteWorker.perform_in(20.seconds, attachment.url)
  end
end