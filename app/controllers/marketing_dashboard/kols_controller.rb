class MarketingDashboard::KolsController < MarketingDashboard::BaseController
  before_action :set_kol, only: [:ban, :disban, :withdraw, :tracks]

  def index
    load_kols
  end

  def show
    @kol = Kol.find params[:id]
  end

  def search
    render 'search' and return if request.method.eql? 'GET'

    search_by = params[:search_key]

    @kols = Kol.where("id LIKE ? OR name LIKE ? OR mobile_number LIKE ? OR email LIKE ?", search_by, search_by, search_by, search_by).paginate(paginate_params)

    render 'index'
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


  def withdraw
    render 'withdraw' and return if request.method.eql? 'GET'

    if @kol.avail_amount.to_f > params[:credits].to_f
      @kol.payout params[:credits].to_f, 'manaual_withdraw'

      respond_to do |format|
        format.html { redirect_to marketing_dashboard_kols_path, notice: 'Payout successfully!' }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to marketing_dashboard_kols_path, alert: 'opps, Payout failed!' }
        format.json { render :status => 422 }
      end
    end
  end

  def edit
    @kol = Kol.find params[:id]
  end

  def update
    @kol = Kol.find params[:id]
    if params[:kol][:mobile_number].blank?
      params[:kol][:mobile_number] = nil
    end
    @kol.update_attributes(params.require(:kol).permit(:mobile_number, :name, :forbid_campaign_time, :kol_level))
    flash[:notice] = "保存成功"
    redirect_to marketing_dashboard_kols_path
  end

  private
  def load_kols
    @kols = if params[:campaign_id]
              Campaign.find(params[:campaign_id]).kols
            else
              if params[:ban]
                Kol.where("forbid_campaign_time is not null and forbid_campaign_time > ?", Time.now)
              else
                Kol.all
              end
            end.order('created_at DESC').paginate(paginate_params)
  end

  def set_kol
    @kol = Kol.find params[:kol_id]
  end
end
