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
      redirect_to  new_public_news_room_follower_path, notice: "You've successfully subscribed."
    else
      render :new
    end
  end

  private

  def follower_params
    params.require(:follower).permit(:email, :list_type, :news_room_id)
  end
  
  def ssl_configured?
    false
  end
end
