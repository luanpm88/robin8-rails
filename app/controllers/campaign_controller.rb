class CampaignController < ApplicationController

  def list
    campaigns = current_user.campaigns
    render json: campaigns, each_serializer: UserSerializer
  end

end
