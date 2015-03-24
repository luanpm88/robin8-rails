class FollowersController < ApplicationController
  layout 'public_pages'
  
  def new
    @news_room = NewsRoom.find_by(subdomain_name: request.subdomain)
    @follower = @news_room.followers.build
  end

  def create
    @mailgun = Mailgun()
    begin
      @mailgun.list_members(params[:list]).add(params[:email], vars: { newsroom_id: params[:newsroom_id] }.to_json)
    rescue Exception
      @mailgun.list_members(params[:list]).update(params[:email], vars: { newsroom_id: params[:newsroom_id] }.to_json)
    end
    redirect_to follow_news_rooms_path, notice: "You've successfully subscribed."
  end

end
