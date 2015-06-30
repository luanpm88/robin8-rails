class CampaignInviteController < ApplicationController
  def index
    invites = kol_signed_in? ? current_kol.campaign_invite : current_user.campaign_invite
    render json: invites, each_serializer: CampaignInviteSerializer
  end

  def create
  end

  def update
    @invite = CampaignInvite.find(params[:id])
    @invite.status = params[:status]
    @invite.save
    render json: @invite
  end
end
