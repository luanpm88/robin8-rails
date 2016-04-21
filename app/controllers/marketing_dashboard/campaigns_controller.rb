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

  def targets
    @campaign = Campaign.find params[:id]

    unmatched_kol_ids = @campaign.get_unmatched_kol_ids

    if @campaign.per_budget_type != 'recruit'
      @kols = Kol.where.not(:id => unmatched_kol_ids).paginate(paginate_params)
    else
      @kols = Kol.where.not(:id => unmatched_kol_ids).where(:id => @campaign.get_specified_kol_ids).paginate(paginate_params)
    end
    @unmatched_kols = Kol.where(:id => unmatched_kol_ids)

    @remove_kol_ids = @campaign.get_remove_kol_ids_by_target
    @black_list_ids = @campaign.get_black_list_kols
    @receive_campaign_kol_ids  = @campaign.get_remove_kol_ids_of_campaign_by_target
    @today_receive_three_times_kol_ids = @campaign.today_receive_three_times_kol_ids
    @title = "campaign: #{@campaign.name} 候选kols(总共 #{@kols.count}人)列表"
  end

  def recruit_targets
    @campaign = Campaign.find params[:id]
    has_applyed_kol_ids = @campaign.campaign_applies.where(status: :applying).pluck(:kol_id)
    @kols = Kol.where(id: has_applyed_kol_ids)
  end

  def agree
    @campaign = Campaign.find params[:campaign_id]
    @campaign.update(:status => :agreed)
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Agreed successfully!'}
      format.json { head :no_content }
    end
  end


  def add_or_remove_recruit_kol
    binding.pry
    kol_id = params[:kol_id]
    campaign_id = params[:campaign_id]
    agree_reason = params[:agree_reason]
    operate = params[:operate]

    @campaign_apply = CampaignApply.find_by(campaign_id: params[:campaign_id], kol_id: params[:kol_id])

    if operate == 'agree'
      campaign_apply.update_attributes(status: "platform_passed", agree_reason: agree_reason)
    end
    if operate == 'cancle'
      campaign_apply.update_attributes(status: "applying", agree_reason: nil)
    end
  end
end
