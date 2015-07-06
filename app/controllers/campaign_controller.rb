class CampaignController < ApplicationController

  def index
    campaigns = kol_signed_in? ? current_kol.campaigns : current_user.campaigns
    render json: campaigns, each_serializer: CampaignsSerializer
  end

end
