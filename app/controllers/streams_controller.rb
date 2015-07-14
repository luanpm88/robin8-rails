class StreamsController < ApplicationController

  def invited_users_list
    current_users=User.where(invited_by_id: needed_user.id)
    invited_id=""
    current_users.all.each do |user|
      invited_id << user.id.to_s << ", "
    end
    return invited_id << needed_user.id.to_s
  end

  def needed_user
    current_user.is_primary ? current_user : current_user.invited_by
  end

  def index
    users_id = invited_users_list
    limit = current_user.current_user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").media_monitoring.map(&:max_count).inject{|sum,x| sum + x }
    @streams = current_user.streams.unscope(where: :user_id).where("user_id IN (#{users_id})").order(:position).limit(limit)
    render json: @streams.to_json
  end

  def create
    stream = current_user.streams.create(stream_params)
    if stream.errors.none?
      render json: stream.to_json
    else
      render json: stream.errors , status: :bad_request
    end
  end

  def destroy
    @stream = Stream.find(params[:id])
    @stream.destroy
    render nothing: true
  end

  def update
    @stream = Stream.find params[:id]
    if @stream.update_attributes(stream_params)
      render json: @stream.to_json
    else
      render json: stream.errors , status: :bad_request
    end
  end

  def stories
    @stream = Stream.find(params[:id]) # ToDo: authorize reading stream
    
    respond_to do |format|
      format.json do
        @stories = fetch_stories
        
        if !params['page'] || params['page'] == 1
          last_story = @stories['stories'].first
          unless last_story.blank?
            last_seen_story_at = Time.parse(last_story['published_at']).utc
            
            if last_seen_story_at != @stream.last_seen_story_at
              @stream.update_column(:last_seen_story_at, last_seen_story_at)
            end
          end
        end
        
        render json: @stories
      end

      format.rss do
        @stories = fetch_stories

        render layout: false,
        locals: {
          stories: @stories,
          stream_id: params[:id],
          topicsForRss: params[:topicsForRss],
          blogsForRss: params[:blogsForRss]
        }
      end

      format.pdf do
        @stories = fetch_stories

        pdf = StreamPdf.new(@stories["stories"])
        send_data pdf.render, filename: "Stream Export",
          type: "application/pdf", disposition: "inline"
      end

      format.png do
        kit = IMGKit.new export_url,
          format: 'png', 'scale-h': nil, 'scale-w': nil, 'crop-h': nil,
          'crop-w': nil, quality: 80, 'crop-x': nil, 'crop-y': nil,
          width: "1366"

        send_data kit.to_png, filename: "Robin8 Export.png",
          type: "image/png", disposition: 'attachment'
      end

      format.docx do
        @stories = fetch_stories
        @stories = summarize_stories(@stories["stories"])
      end

      format.html do
        @stories = fetch_stories
        @colorize_background = params[:colorize_background]

        @stories = summarize_stories(@stories["stories"])
        render layout: false
      end
    end
  end

  def order
    params[:ids].each_with_index do |id, index|
      stream = Stream.find(id)
      stream.update_attribute(:position, index.to_i+1)
    end
    render nothing: true
  end

  def stream_params
    params.require(:stream).permit(:user_id, :name, :sort_column, :published_at, topics: [:id, :text], blogs: [:id, :text], keywords: [:id, :text, :type])
  end

  private

  def export_url
    if Rails.env.development?
      scheme = "http"
      host = "localhost:3001"
    else
      scheme = "https"
      host = Rails.application.secrets.host
    end

    request_url = URI.parse("#{scheme}://#{host}/streams/#{params[:id]}/stories/")
    query_params = {}
    query_params[:per_page] = params[:per_page] || 10
    query_params[:colorize_background] = params[:colorize_background]
    query_params[:published_at] = params[:published_at] if params[:published_at]

    request_url.query = URI.encode_www_form(query_params)
    request_url.to_s
  end

  def fetch_stories
    req_params = @stream.query_params
    req_params.merge!(page: URI.decode(params[:page])) if params[:page]
    req_params.merge!(per_page: params[:per_page]) if params[:per_page]
    req_params.merge!(published_at: params[:published_at]) if params[:published_at]

    endpoint = "/uniq_stories"

    uri = URI(Rails.application.secrets.robin_api_url + endpoint)
    uri.query = URI.encode_www_form req_params

    req = Net::HTTP::Get.new(uri)
    req.basic_auth Rails.application.secrets.robin_api_user, Rails.application.secrets.robin_api_pass

    res = Net::HTTP.start(uri.hostname) {|http| http.request(req) }
    res.code == '200' ? JSON.parse(res.body) : {}
  end

  def summarize_stories(stories)
    stories_summary = {}
    text_api_client = AylienTextApi::Client.new
    threads = []

    stories.each do |story|
      threads << Thread.new do
        stories_summary[story["id"]] = text_api_client.summarize title: story["title"],
          text: story["description"]
      end
    end

    threads.each(&:join)

    stories.map do |s|
      s['summary'] = stories_summary[s["id"]][:sentences]
      s
    end
  end
end
