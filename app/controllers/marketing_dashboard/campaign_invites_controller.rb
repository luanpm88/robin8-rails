class MarketingDashboard::CampaignInvitesController < MarketingDashboard::BaseController
  before_action :set_campaign_invite, only: [:pass, :reject]

  def index
    @campaign_invites = CampaignInvite.where.not(:screenshot => '').paginate(paginate_params)
  end

  def pending
    valid_period = Campaign::SettleWaitTimeForBrand
    @campaign_invites = CampaignInvite.joins(:campaign, :kol).where.not(:screenshot => "").where(:img_status => :pending).where(:status => ['approved', 'finished']).where("campaigns.deadline > ?", Time.now-valid_period).paginate(paginate_params)
  end

  def passed
    @campaign_invites = CampaignInvite.where(:img_status => 'passed').paginate(paginate_params)

    render 'index'
  end

  def rejected
    @campaign_invites = CampaignInvite.where(:img_status => 'reject').paginate(paginate_params)

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
    @campaign_invite.screenshot_reject

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
