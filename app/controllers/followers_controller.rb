class FollowersController < ApplicationController
  layout 'public_pages'
  
  def new
    @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
    @follower = @news_room.followers.build
  end

  def create
    @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
    @follower = @news_room.followers.build follower_params
    if @follower.save
      # @mailgun = Mailgun()
      # begin
      #   @mailgun.list_members(params[:list]).add(params[:email], vars: { newsroom_id: params[:newsroom_id] }.to_json)
      # rescue Exception
      #   @mailgun.list_members(params[:list]).update(params[:email], vars: { newsroom_id: params[:newsroom_id] }.to_json)
      # end
      redirect_to follow_news_rooms_path, notice: "You've successfully subscribed."
    else
      render :new
    end
  end

  private

    def follower_params
      params.require(:follower).permit(:email, :list_type, :news_room_id)
    end

end
