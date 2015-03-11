class StreamsController < ApplicationController

  def index
    @streams = current_user.streams.order(:position)
    render json: @streams.to_json
  end

  def create
    stream = current_user.streams.create(stream_params)
    if stream.errors.none?
      render json: stream.to_json
    else
      render nothing: true
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
      render nothing: true
    end
  end

  def stories
    stream = Stream.find(params[:id]) # ToDo: authorize reading stream
    req_params = stream.query_params
    req_params.merge!(cursor: URI.decode(params[:cursor])) if params[:cursor]

    uri = URI(Rails.application.secrets.robin_api_url + '/stories')
    uri.query = URI.encode_www_form req_params

    req = Net::HTTP::Get.new(uri)
    req.basic_auth Rails.application.secrets.robin_api_user, Rails.application.secrets.robin_api_pass

    res = Net::HTTP.start(uri.hostname) {|http| http.request(req) }
    parsed_res = res.code == '200' ? JSON.parse(res.body) : {}
    respond_to do |format|
      format.json { render json: parsed_res}
      format.rss {
        render layout: false,
        locals: {
          stories: parsed_res,
          stream_id: params[:id],
          topicsForRss: params[:topicsForRss],
          blogsForRss: params[:blogsForRss]
        }
      }
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
    params.require(:stream).permit(:user_id, :name, :sort_column, :published_at, topics: [:id, :text], blogs: [:id, :text])
  end

end
