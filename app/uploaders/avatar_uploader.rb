class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :qiniu

  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/avatars"
  end

  include CarrierWave::MimeTypes
  process :set_content_type

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(version_name = "")
  end

  def filename
    if super.present?
      uploader_secure_token = SecureRandom.hex
      Rails.logger.debug("(BaseUploader.filename) #{uploader_secure_token}")
      "#{uploader_secure_token}#{File.extname(file.path).downcase}" rescue "#{uploader_secure_token}#{File.extname(default_url).downcase}"
    end
  end


end
