class CampaignController < ApplicationController

  def index
    campaigns = kol_signed_in? ? current_kol.campaign : current_user.campaign
    render json: campaigns, each_serializer: CampaignsSerializer
  end

end
