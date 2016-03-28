class MarketingDashboard::CampaignShowsController < MarketingDashboard::BaseController
  def index
    @campaign_shows = CampaignShow.where(campaign_id: params[:campaign_id]).paginate(paginate_params)

    render 'marketing_dashboard/shared/_campaign_show_index'
  end
end
