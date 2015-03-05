class FollowersController < ApplicationController
  
  def add
    @mailgun = Mailgun()
    begin
      @mailgun.list_members(params[:list]).add(params[:email], vars: { newsroom_id: params[:newsroom_id] }.to_json)
    rescue Exception
      @mailgun.list_members(params[:list]).update(params[:email], vars: { newsroom_id: params[:newsroom_id] }.to_json)
    end
    render json: {}
  end

end
