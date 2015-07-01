class CampaignInviteController < ApplicationController
  def index
    invites = kol_signed_in? ? current_kol.campaign_invite : current_user.campaign_invite
    render json: invites.where("status = ?", ''), each_serializer: CampaignInviteSerializer
  end

  def create
  end

  def update
    @invite = current_kol.campaign_invite.find(params[:id])
    if @invite.kol != current_kol
      render json: {errors: {permission_denied: 'You must be authorized'}}, :status => :unauthorized
    else
      @invite.status = params[:status]
      @invite.save
      render json: @invite
    end
  end
end
