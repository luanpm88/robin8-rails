class MarketingDashboard::CreationSelectedKolsController < MarketingDashboard::BaseController

  def index
    @q    = CreationSelectedKol.ransack(params[:q])
    @kols = @q.result.order(updated_at: :desc).paginate(paginate_params)
  end

  def finished
    @kol = CreationSelectedKol.find params[:id]
    @kol.update_attributes(status: "finished") if @kol.status == "approved"

    flash[:alert] = "支付成功"

    redirect_to marketing_dashboard_creation_selected_kols_path(q: {status_eq: :approved})
  end

end