module Uploader
  module FileUploader
    def self.image_uploader(image = nil)
      return  unless image
      uploader = AvatarUploader.new
      uploader.store!(image)
      uploader.url
    end
  end
end