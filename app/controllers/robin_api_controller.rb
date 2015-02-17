class RobinApiController < ApplicationController

  before_action :authenticate_user!

  def proxy
    uri = URI(Rails.application.secrets.robin_api_url + request.fullpath)
    req = Net::HTTP::Get.new(uri)
    req.basic_auth Rails.application.secrets.robin_api_user, Rails.application.secrets.robin_api_pass
    res = Net::HTTP.start(uri.hostname) {|http| http.request(req) }
    new_array = []

    type = request.fullpath.split('/').last.split('?').first

    JSON.parse(res.body)["#{type}"].each  do |topic|
      new_topic = {}
      new_topic['id'] = topic['id']
      new_topic['text'] = topic['name']
      new_array << new_topic
    end
    
    render json: new_array
  end

end
