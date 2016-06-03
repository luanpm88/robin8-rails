class MarketingDashboard::CampaignInvitesController < MarketingDashboard::BaseController
  before_action :set_campaign_invite, only: [:pass, :reject]

  def index
    if params[:campaign_id]
      @campaign_invites = Campaign.find(params[:campaign_id]).campaign_invites.order('created_at DESC').paginate(paginate_params)
    else
      @campaign_invites = CampaignInvite.where.not(:screenshot => '').order('created_at DESC').paginate(paginate_params)
    end
  end

  def pending
    # valid_period = Campaign::SettleWaitTimeForBrand
    # @campaign_invites = CampaignInvite.joins(:campaign, :kol).where.not(:screenshot => "").where(:img_status => :pending).where(:status => ['approved', 'finished']).where("campaigns.deadline > ?", Time.now-valid_period).paginate(paginate_params)
    if params[:kol_id]
      invites = CampaignInvite.where(:kol_id => params[:kol_id])
    else
      invites = CampaignInvite.all
    end
    params[:per_page] = 12
    if params[:observer_status].to_i == 2
      @campaign_invites = invites.where(:img_status => :pending, :observer_status => 2).where("screenshot is not NULL").order('created_at DESC').paginate(paginate_params)
    elsif params[:observer_status].to_i == 1
      @campaign_invites = invites.where(:img_status => :pending, :observer_status => 1).where("screenshot is not NULL").order('created_at DESC').paginate(paginate_params)
    else
      @campaign_invites = invites.where(:img_status => :pending).where("screenshot is not NULL").order('created_at DESC').paginate(paginate_params)
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

end
