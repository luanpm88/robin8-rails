class CampaignInviteController < ApplicationController
  def index
    someone = current_user
    someone = current_kol if someone.nil?
    invites = someone.nil? ? [] : someone.campaign_invites.joins("RIGHT JOIN campaigns ON campaign_invites.campaign_id = campaigns.id").where("campaigns.deadline > ? and (campaign_invites.status IS NULL or campaign_invites.status='')", Time.zone.now.beginning_of_day)
    render json: invites, each_serializer: CampaignInviteSerializer
  end

  def create
  end

  def update
    invite = []
    unless params[:campaign_id].blank?
      invite = CampaignInvite.where(:campaign_id => params[:campaign_id])
      invite = invite.first
    else
      invite = CampaignInvite.find(params[:id])
    end
    if invite.kol != current_kol
      render json: {errors: {permission_denied: 'You must be authorized'}}, :status => :unauthorized
    else
      invite.status = params[:status]
      if params[:status] == "D"
        invite.decline_date = DateTime.now()
      end
      invite.save
      if params[:status] == "A"
        a = Article.new(kol_id: current_kol.id, campaign_id: invite.campaign.id)
        a.save
      end
      render json: invite
    end
  end
end
