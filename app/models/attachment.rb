class Attachment < ActiveRecord::Base
  VALID_TYPES = ['image', 'file', 'video']
  belongs_to :imageable, polymorphic: true
  validates_inclusion_of :attachment_type, in: VALID_TYPES

  after_create do |attachment|
    AmazonStorageWorker.perform_async("attachment", attachment.id, attachment.url, nil, :url)
    AmazonStorageWorker.perform_async("attachment", attachment.id, attachment.thumbnail, nil, :thumbnail)
  end

  after_destroy do |attachment|
    AmazonDeleteWorker.perform_in(20.seconds, attachment.url)
    AmazonDeleteWorker.perform_in(20.seconds, attachment.thumbnail)
  end

  def get_correct_url
    case attachment_type
    when 'image'
      url
    when 'video'
      '/assets/video.png'
    when 'file'
      '/assets/file.png'
    end
  end
end