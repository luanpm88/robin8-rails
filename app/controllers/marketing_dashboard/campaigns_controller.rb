class MarketingDashboard::CampaignsController < MarketingDashboard::BaseController
  def index
    @campaigns = if params[:kol_id]
                   Kol.find(params[:kol_id]).campaigns.order('created_at DESC')
                 elsif params[:user_id]
                  User.find(params[:user_id]).campaigns.order('created_at DESC')
                 else
                   Campaign.all.order('created_at DESC')
                 end.paginate(paginate_params)
  end

  def pending
    @campaigns = Campaign.all.where(status: 'unexecute').order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def show
    @campaign = Campaign.find params[:id]
  end

  def agreed
    @campaigns = Campaign.all.where.not(status: 'unexecute').order('created_at DESC').paginate(paginate_params)
    render 'index'
  end

  def add_target
    CampaignTarget.create(params.require(:campaign_target).permit(:target_type_text, :target_content).merge(:campaign_id => params[:id]))
    redirect_to targets_marketing_dashboard_campaign_path(:id => params[:id])
  end

  def stop
    @campaign = Campaign.find params[:id]
    @campaign.finish("stop by admin")
    redirect_to :action => :index
  end

  def targets
    @campaign = Campaign.find params[:id]

    unmatched_kol_ids = @campaign.get_unmatched_kol_ids

    @kols = Kol.where.not(:id => unmatched_kol_ids).paginate(paginate_params)
    @unmatched_kols = Kol.where(:id => unmatched_kol_ids)

    @remove_kol_ids = @campaign.get_remove_kol_ids_by_target
    @black_list_ids = @campaign.get_black_list_kols
    @receive_campaign_kol_ids  = @campaign.get_remove_kol_ids_of_campaign_by_target
    @today_receive_three_times_kol_ids = @campaign.today_receive_three_times_kol_ids
    @title = "campaign: #{@campaign.name} 候选kols(总共 #{@kols.count}人)列表"
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
