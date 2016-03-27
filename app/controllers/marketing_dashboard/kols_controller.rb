class MarketingDashboard::KolsController < MarketingDashboard::BaseController
  before_action :set_kol, only: [:ban, :disban]

  def index
    load_kols
  end

  def ban
    render 'ban' and return if request.method.eql? 'GET'

    @kol.update(forbid_campaign_time: params[:forbid_time])

    respond_to do |format|
      format.html { redirect_to marketing_dashboard_kols_path, notice: 'Ban successfully!' }
      format.json { head :no_content }
    end

  end

  def disban
    @kol.update(forbid_campaign_time: Time.now)
    
    respond_to do |format|
      format.html { redirect_to marketing_dashboard_kols_path, notice: 'Disban successfully!' }
      format.json { head :no_content }
    end
  end

  private
  def load_kols
    @kols = if params[:campaign_id]
              Campaign.find_by(params[:campaign_id]).kols
            else
              Kol.all
            end.paginate(paginate_params)
  end

  def set_kol
    @kol = Kol.find params[:kol_id]
  end
end
