class MarketingDashboard::CreationSelectedKolsController < MarketingDashboard::BaseController

  def index
    @q    = CreationSelectedKol.ransack(params[:q])
    @kols = @q.result.order(updated_at: :desc).paginate(paginate_params)
  end

end