class MarketingDashboard::CampaignShowsController < MarketingDashboard::BaseController
  def index
    @campaign_shows = if params[:campaign_id]
                        CampaignShow.where(campaign_id: params[:campaign_id])
                      elsif params[:kol_id]
                        CampaignShow.where(kol_id: params[:kol_id])
                      elsif params[:campaign_invite_id]
                        @campaign_invite = CampaignInvite.find(params[:campaign_invite_id])
                        CampaignShow.where(campaign_id: @campaign_invite.campaign.id, kol_id: @campaign_invite.kol.id)
                      end.order('created_at DESC').paginate(paginate_params)
  end

end
