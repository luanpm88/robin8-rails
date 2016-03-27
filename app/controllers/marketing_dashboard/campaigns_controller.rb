class MarketingDashboard::CampaignsController < MarketingDashboard::BaseController
  def index
    @campaigns = Campaign.all.paginate(paginate_params)
  end

  def pending
    @campaigns = Campaign.all.where(status: 'pending').paginate(paginate_params)

    render 'index'
  end

  def agreed
    @campaigns = Campaign.all.where.not(status: 'pending').paginate(paginate_params)

    render 'index'
  end

  def agree
    @campaign = Campaign.find params[:campaign_id]
    @campaign.update(:status => :agreed)
    respond_to do |format|
      format.html { redirect_to agreed_marketing_dashboard_campaigns_path, notice: 'Agreed successfully!'}
      format.json { head :no_content }
    end
  end

end
