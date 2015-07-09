require 'base64'

module ImageProxyHelper
  def proxy_image_tag(images, options = nil)
    options[:src] = image_proxy_path(images: Base64.encode64(images))
    tag("img", options)
  end
  
  def proxy_image_tag_url(images, options = nil)
    options[:src] = image_proxy_url(images: Base64.encode64(images))
    tag("img", options)
  end
end
