class RobinApiController < ApplicationController
  before_action :authenticate_user!, :set_client

  def suggested_authors
    response = @client.suggested_authors params
    ids = response[:authors].map{|a| a[:id]}
    
    render json: merge_stats_with_authors(response[:authors], author_stats(ids))
  end
  
  def influencers
    response = @client.influencers params
    
    render json: response[:influencers].map{|key, val| val}
  end
  
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

  private
  
  def set_client
    @client = AylienPressrApi::Client.new
  end
  
  def author_stats(ids)
    threads = {}
    ids.each do |id|
      threads[id] = Thread.new do
        @client.author_stats id: id
      end
    end
    threads.each(&:join)
    threads.inject({}) do |memo, val|
      memo[val[0]] = val[1].value
      memo
    end
  end
  
  def merge_stats_with_authors(authors, author_stats)
    authors.collect do |author|
      author_stats[author[:id]].delete(:id)
      author[:stats] = author_stats[author[:id]]
      author
    end
  end
end
