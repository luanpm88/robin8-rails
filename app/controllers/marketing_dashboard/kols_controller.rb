class MarketingDashboard::KolsController < MarketingDashboard::BaseController
  def index
    load_kols
  end

  private
  def load_kols
    @kols = if params[:campaign_id]
              Campaign.find_by(params[:campaign_id]).kols
            else
              Kol.all
            end.paginate(paginate_params)
  end
end
