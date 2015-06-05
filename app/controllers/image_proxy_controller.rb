require 'base64'
require 'net/http'

class ImageProxyController < ApplicationController
  def get
    url = URI.parse(Base64.decode64(params[:url]))
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https") ? true : false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(url.request_uri)
    image = http.request(request)
    
    send_data image.body, type: image.content_type, disposition: 'inline'
  end
end
