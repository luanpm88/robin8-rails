class MarketingDashboard::EWallets::BillsController < MarketingDashboard::BaseController

  def index
    params[:status] = 'successful' unless params[:status]

    @transtions = EWallet::Transtion.includes(:kol).where(status: params[:status]).order(created_at: :desc)

    respond_to do |format|
      format.html do
        @transtions = @transtions.paginate(paginate_params)
        render 'index'
      end

      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"put_bills#{Time.now.strftime("%Y%m%d%H%M%S")}.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
        render 'index'
      end
    end
  end

end
