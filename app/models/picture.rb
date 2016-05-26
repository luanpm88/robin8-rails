class Picture < ActiveRecord::Base
  mount_uploader :name, ImageUploader

  belongs_to :imageable, polymorphic: true

  def url
    self.name.url
  end
end
