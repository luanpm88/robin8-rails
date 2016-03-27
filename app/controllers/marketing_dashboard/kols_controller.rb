class MarketingDashboard::KolsController < MarketingDashboard::BaseController
  def index
    @kols = if params[:campaign_id]
	      Campaign.find_by(params[:campaign_id]).kols.paginate(:page => 1, :per_page => 20)
	    else
	      Kol.all.paginate(:page => 1, :per_page => 20)
	    end
  end
end
