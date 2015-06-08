class ImageProxyController < ApplicationController
  def get
    urls = JSON.parse Base64.decode64(params[:images])
    
    response = get_image(urls, nil)
    send_data response.body, type: response.content_type, disposition: 'inline'
  end
  
  private
  
  def get_image(urls, response)
    if (response && response.code == 200) || urls.blank?
      response
    else
      url = URI.parse(urls.shift)
      response = HTTParty.get url.to_s
      
      get_image(urls, response)
    end
  end
end
