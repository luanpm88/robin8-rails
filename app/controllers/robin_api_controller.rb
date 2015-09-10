class RobinApiController < ApplicationController
  before_action :authenticate_user!, :set_client

  def suggested_authors
    params["per_page"] = 200
    params["included_email"] = true
    response = @client.suggested_authors params
    authors = unless response[:authors].blank?
      authors_response = uniq_authors(response[:authors])
      ids = authors_response.map{|a| a[:id]}
      @max_score = authors_response.first[:score]
      @min_score = authors_response.last[:score]
      authors_response.map do |author|
        level_of_interest = calculate_level_of_interest(author[:score],
          full_name(author[:first_name], author[:last_name]))
        author[:level_of_interest] = level_of_interest
        author[:full_name] = full_name(author[:first_name], author[:last_name])
        author
      end
    else
      []
    end

    params["included_email"] = false
    response = @client.suggested_authors params
    authors2 = unless response[:authors].blank?
      authors_response = uniq_authors(response[:authors])
      ids = authors_response.map{|a| a[:id]}
      @max_score = authors_response.first[:score]
      @min_score = authors_response.last[:score]
      authors_response.map do |author|
        level_of_interest = calculate_level_of_interest(author[:score],
                                                        full_name(author[:first_name], author[:last_name]))
        author[:level_of_interest] = level_of_interest
        author[:full_name] = full_name(author[:first_name], author[:last_name])
        author
      end
    else
      []
    end

    authors = authors+authors2

    authors = authors.sort_by { |v| v[:level_of_interest]}.reverse
    authors = uniq_authors(authors)
    #authors = authors.sort{ |x, y| x[:index] <=> y[:index] }[0...100]
    puts authors
    puts authors.count


    render json: authors
  end

  def related_stories
    response = @client.related_stories! params

    render json: response
  end

  def stories
    response = @client.stories! params.merge({
      "group_fields[]" => "signature",
      group_limit: 1,
    })

    uniq_stories = response[:grouped][:signature][:groups].map do |group|
      group[:stories].first
    end

    render json: {stories: uniq_stories}
  end

  def influencers
    response = @client.influencers params

    render json: response[:influencers].map{|key, val| val}
  end

  def authors
    params["per_page"] = 200
    response = @client.authors params

    authors_response = uniq_authors(response[:authors])

    authors = authors_response.map do |author|
      author[:full_name] = full_name(author[:first_name], author[:last_name])
      author
    end

    render json: authors
  end

  def author_stats
    response = @client.author_stats id: params[:id]

    render json: response
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

  def calculate_level_of_interest(score, author_name)
    unless defined?(@max_min)
      @max_min = calculate_max_min(author_name)
    end
    a = @max_min[0]; b = @max_min[1];

    normalized_score = unless @max_score == @min_score
      x_min_max = @max_score - @min_score
      delta_b_a = b - a
      a + ((score - @min_score) * delta_b_a / x_min_max)
    else
      a
    end

    normalized_score.nil? ? 0 : normalized_score.round(2)
  end

  def uniq_authors(authors)
    uniq_authors = authors.each_with_index.inject({}) do |memo, item|
      value, index = item

      if memo[value[:email]]
        previous_author = memo[value[:email]]

        memo[value[:email]][:blog_names] << value[:blog_name]
        memo[value[:email]][:blog_names].uniq!
      else
        new_author = {
          id: value[:id],
          first_name: value[:first_name],
          last_name: value[:last_name],
          full_name: value[:full_name],
          email: value[:email],
          blog_names: [value[:blog_name]],
          avatar_url: value[:avatar_url],
          score: value[:score],
          index: index,
          level_of_interest: value[:level_of_interest]
        }

        memo[value[:email]] = new_author
      end

      memo
    end

    uniq_authors.values.sort{ |x, y| x[:index] <=> y[:index] }#[0...100]
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
