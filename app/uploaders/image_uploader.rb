class ImageUploader < CarrierWave::Uploader::Base
  # 默认图片
  # encoding: utf-8
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :fog

  storage :qiniu

  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    if super.present?
      uploader_secure_token = secure_token(10)
      Rails.logger.debug("(BaseUploader.filename) #{uploader_secure_token}")
      "#{uploader_secure_token}#{File.extname(file.path).downcase}" rescue "#{uploader_secure_token}#{File.extname(default_url).downcase}"
    end
    # "#{secure_token(10)}.#{file.extension}" if original_filename.present?
  end

  include CarrierWave::MimeTypes
  process :set_content_type

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url(version_name = "")
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  def url(version_name = "")
    @url ||= super({}) || default_url(version_name)
    return if @url.blank?
    version_name = version_name.to_s
    return @url if version_name.blank?
    [@url, version_name].join("!")
  end

  protected
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end


end
