class MarketingDashboard::CampaignInvitesController < MarketingDashboard::BaseController
  before_action :set_campaign_invite, only: [:pass, :reject]

  def index
    base_invites = CampaignInvite.where.not(:screenshot => '')
    if search_key
      if params[:search_helper][:item_type] == "kol"
        kol = Kol.where("id=? or mobile_number=?", params[:search_helper][:key], params[:search_helper][:key]).first
        if kol
          base_invites = base_invites.where(:kol_id => kol.id)
        end
      elsif params[:search_helper][:item_type] == "campaign"
        base_invites = base_invites.where(:campaign_id => params[:search_helper][:key])
      end
    end
    
    if params[:campaign_id]
      @campaign_invites = Campaign.find(params[:campaign_id]).campaign_invites.order('created_at DESC').paginate(paginate_params)
    else
      @campaign_invites = base_invites.order('created_at DESC').paginate(paginate_params)
    end
  end

  def pending
    # valid_period = Campaign::SettleWaitTimeForBrand
    # @campaign_invites = CampaignInvite.joins(:campaign, :kol).where.not(:screenshot => "").where(:img_status => :pending).where(:status => ['approved', 'finished']).where("campaigns.deadline > ?", Time.now-valid_period).paginate(paginate_params)
    base_invites = CampaignInvite.where.not(:screenshot => '').where(:img_status => :pending)
    if search_key
      if params[:search_helper][:item_type] == "kol"
        kol = Kol.where("id=? or mobile_number=?", params[:search_helper][:key], params[:search_helper][:key]).first
        if kol
          base_invites = base_invites.where(:kol_id => kol.id)
        end
      elsif params[:search_helper][:item_type] == "campaign"
        base_invites = base_invites.where(:campaign_id => params[:search_helper][:key])
      end
    end

    if params[:kol_id]
      base_invites = base_invites.where(:kol_id => params[:kol_id])
    end
    params[:per_page] = 12
    if params[:per_action_type] == "post"
      base_invites = base_invites.joins(:campaign).where("per_budget_type='post'")
    end

    if params[:observer_status].to_i == 2
      @campaign_invites = base_invites.where(:observer_status => 2).where("screenshot is not NULL").order('created_at DESC').paginate(paginate_params)
    elsif params[:observer_status].to_i == 1
      @campaign_invites = base_invites.where(:observer_status => 1).where("screenshot is not NULL").order('created_at DESC').paginate(paginate_params)
    else
      @campaign_invites = base_invites.where("screenshot is not NULL").order('created_at DESC').paginate(paginate_params)
    end
    render :pending_new
  end

  def passed
    @campaign_invites = CampaignInvite.where(:img_status => 'passed').order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def rejected
    @campaign_invites = CampaignInvite.where(:img_status => 'rejected').order('created_at DESC').paginate(paginate_params)
    render 'index'
  end

  def pass
    @campaign_invite.screenshot_pass

    respond_to do |format|
      format.html { redirect_to pending_marketing_dashboard_campaign_invites_path, notice: 'Pass successfully!'}
      format.json { head :no_content }
    end
  end

  def reject
    render 'reject' and return if request.method.eql? 'GET'
    @campaign_invite.screenshot_reject(params[:reject_reason].present? ? params[:reject_reason] : params[:common_reject_reason])
    respond_to do |format|
      format.html { redirect_to pending_marketing_dashboard_campaign_invites_path, notice: 'Reject successfully!'}
      format.json { head :no_content }
    end
  end

  private
  def set_campaign_invite
    @campaign_invite = CampaignInvite.find params[:campaign_invite_id]
  end

  def search_key
    if params[:search_helper]
      @search_helper = SearchHelper.new(params.require(:search_helper).permit(:key, :item_type))
      return params[:search_helper][:key]
    end
  end
end
