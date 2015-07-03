class CampaignInviteController < ApplicationController
  def index
    someone = current_user
    someone = current_kol if someone.nil?
    invites = someone.nil? ? [] : someone.campaign_invites
    render json: invites, each_serializer: CampaignInviteSerializer
  end

  def create
  end

  def update
    invite = CampaignInvite.find(params[:id])
    if invite.kol != current_kol
      render json: {errors: {permission_denied: 'You must be authorized'}}, :status => :unauthorized
    else
      invite.status = params[:status]
      invite.save
      render json: invite
    end
  end
end
