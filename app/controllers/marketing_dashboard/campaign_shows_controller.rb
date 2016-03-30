class MarketingDashboard::CampaignShowsController < MarketingDashboard::BaseController
  def index
    @campaign_shows = if params[:campaign_id]
                        CampaignShow.where(campaign_id: params[:campaign_id])
                      elsif params[:kol_id]
                        CampaignShow.where(kol_id: params[:kol_id])
                      end.order('created_at DESC').paginate(paginate_params)
  end

end
