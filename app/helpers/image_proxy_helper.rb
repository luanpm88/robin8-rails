require 'base64'

module ImageProxyHelper
  def proxy_image_tag(source, options = nil)
    options[:src] = "/image_proxy/#{URI.encode_www_form_component Base64.encode64(source)}"
    tag("img", options)
  end
end
