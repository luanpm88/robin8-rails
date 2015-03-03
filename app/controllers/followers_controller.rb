class FollowersController < ApplicationController
  
  def add
    @mailgun = Mailgun()
    @mailgun.list_members(params[:list]).add(params[:email])
    render json: {}
  end

end
