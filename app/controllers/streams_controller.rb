class StreamsController < ApplicationController

  def index
    @streams = current_user.streams
    render json: @streams.to_json
  end

  def create
    if current_user.streams.create(stream_params)
      render json: {}
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

  def stream_params
    params.require(:stream).permit(:user_id, :name, :topics, :sources)
  end

end
