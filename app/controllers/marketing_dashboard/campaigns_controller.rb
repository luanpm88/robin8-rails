class MarketingDashboard::CampaignsController < MarketingDashboard::BaseController
  def index
    @campaigns = if params[:kol_id]
                   Kol.find(params[:kol_id]).campaigns.order('created_at DESC')
                 else
                   Campaign.all.order('created_at DESC')
                 end.paginate(paginate_params)
  end

  def pending
    @campaigns = Campaign.all.where(status: 'pending').order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def agreed
    @campaigns = Campaign.all.where.not(status: 'pending').order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def agree
    @campaign = Campaign.find params[:campaign_id]
    @campaign.update(:status => :agreed)
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Agreed successfully!'}
      format.json { head :no_content }
    end
  end

end
