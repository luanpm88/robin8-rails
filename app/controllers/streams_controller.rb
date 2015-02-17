class StreamsController < ApplicationController

  def index
    @streams = current_user.streams
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
      render json: {}
    else
      render json: {}
    end
  end

  def stories
    stream = Stream.find(params[:id]) # ToDo: authorize reading stream

    uri = URI(Rails.application.secrets.robin_api_url + '/stories')
    uri.query = URI.encode_www_form stream.query_params

    req = Net::HTTP::Get.new(uri)
    req.basic_auth Rails.application.secrets.robin_api_user, Rails.application.secrets.robin_api_pass

    res = Net::HTTP.start(uri.hostname) {|http| http.request(req) }
    render json: res.body
  end

  def stream_params
    params.require(:stream).permit(:user_id, :name, :sort_column, topics: [:id, :name], blogs: [:id, :name])
  end

end
