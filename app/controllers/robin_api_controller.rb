class RobinApiController < ApplicationController
  before_action :authenticate_user!, :set_client

  def suggested_authors
    response = @client.suggested_authors params
    ids = response[:authors].map{|a| a[:id]}
    @max_score = response[:authors].first[:score]
    @min_score = response[:authors].last[:score]
    authors = response[:authors].map do |author|
      level_of_interest = calculate_level_of_interest(author[:score], 
        full_name(author[:first_name], author[:last_name]))
      author[:level_of_interest] = level_of_interest
      author[:full_name] = full_name(author[:first_name], author[:last_name])
      author
    end
    render json: merge_stats_with_authors(authors, author_stats(ids))
  end
  
  def related_stories
    response = @client.related_stories! params

    render json: response
  end
  
  def influencers
    response = @client.influencers params
    
    render json: response[:influencers].map{|key, val| val}.take(25)
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
  
  def calculate_level_of_interest(score, author_name) 
    unless defined?(@max_min)
      @max_min = calculate_max_min(author_name)
    end
    a = @max_min[0]; b = @max_min[1];
    x_min_max = @max_score - @min_score
    delta_b_a = b - a
    normalized_score = a + ((score - @min_score) * delta_b_a / x_min_max)
    normalized_score.round(2)
  end
  
  def calculate_max_min(author_name)
    min_max_arr = {
      0 => [65.68, 99.56], 1 => [66.23, 98.85], 2 => [67.38, 97.94], 
      3 => [68.15, 96.02], 4 => [69.08, 95.16], 5 => [70.12, 94.42],
      6 => [66.74, 93.62], 7 => [69.36, 92.23], 8 => [70.52, 91.94],
      9 => [66.03, 90.09]
    }
    
    result = unless author_name.blank?
      author_name.bytes.inject(0){|memo, a| memo + a}
    else
      0
    end

    key = result % 10

    min_max_arr[key]
  end
  
  def full_name(first_name, last_name)
    if !first_name.blank? && !last_name.blank?
      "#{first_name} #{last_name}"
    elsif !first_name.blank?
      first_name
    elsif !last_name.blank?
      last_name
    else
      "N/A"
    end
  end
end
