class MarketingDashboard::CampaignInvitesController < MarketingDashboard::BaseController
  # before_action :set_campaign_invite, only: [:pass, :reject]

  def index
    authorize! :read, CampaignInvite
    @campaign_invites = CampaignInvite.includes(:campaign).includes(kol: [:admintags]).where("screenshot is not NULL")
    @campaign_invites = @campaign_invites.where("campaign_id = ? " , params[:campaign_id] ) if params[:campaign_id]

    @q = @campaign_invites.ransack(params[:q])
    @campaign_invites = @q.result.order('created_at DESC')
    respond_to do |format|
      format.html do
        @campaign_invites = @campaign_invites.paginate(paginate_params)
        render 'index'
      end

      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"截图审核记录#{Time.now.strftime("%Y%m%d%H%M%S")}.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
        render 'index'
      end
    end
  end

  def pending
    @campaign_invites = CampaignInvite.where("screenshot is not NULL").where(:img_status => :pending)
    # valid_period = Campaign::SettleWaitTimeForBrand
    # @campaign_invites = CampaignInvite.joins(:campaign, :kol)
    #   .where.not(:screenshot => "").where(:img_status => :pending)
    #   .where(:status => ['approved', 'finished'])
    #   .where("campaigns.deadline > ?", Time.now-valid_period)
    #   .paginate(paginate_params)
    @campaign_invites = @campaign_invites.where(:kol_id => params[:kol_id]) if params[:kol_id]

    @q = @campaign_invites.ransack(params[:q])
    @campaign_invites = @q.result.order('created_at DESC').paginate(paginate_params)

    @batch_visible = true

    render :index
  end

  def passed
    @campaign_invites = CampaignInvite.where(:img_status => 'passed')
    @q = @campaign_invites.ransack(params[:q])
    @campaign_invites = @q.result.order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def rejected
    @campaign_invites = CampaignInvite.where(:img_status => 'rejected')
    @q = @campaign_invites.ransack(params[:q])
    @campaign_invites = @q.result.order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def change_multi_img_status
    unless can?(:update, CampaignInvite)
      return render json: {result: 'no_auth'}
    end
    ids = params[:ids]

    @campaign_invites = CampaignInvite.where :id => ids
    if params[:status] == "agree"
      @campaign_invites.each { |c| c.screenshot_pass }
      return render json: { result: 'agree' }
    end


    if params[:status] == "reject"
      if params[:reject_reason].present?
        reject_reason = params[:reject_reason]
      else
        reject_reason = params[:common_reject_reason]
      end
      @campaign_invites.each do |c|
        c.screenshot_reject reject_reason
      end

      return render json: { result: 'reject' }
    end
    return render json: { result: 'error' }
  end

  # def pass
  #   authorize! :write, CampaignInvite
  #   @campaign_invite.screenshot_pass
  #
  #   respond_to do |format|
  #     format.html { redirect_to pending_marketing_dashboard_campaign_invites_path, notice: 'Pass successfully!'}
  #     format.json { head :no_content }
  #   end
  # end
  #
  # def reject
  #   authorize! :write, CampaignInvite
  #   render 'reject' and return if request.method.eql? 'GET'
  #   @campaign_invite.screenshot_reject(params[:reject_reason].present? ? params[:reject_reason] : params[:common_reject_reason])
  #   respond_to do |format|
  #     format.html { redirect_to pending_marketing_dashboard_campaign_invites_path, notice: 'Reject successfully!'}
  #     format.json { head :no_content }
  #   end
  # end

  private
  # def set_campaign_invite
  #   @campaign_invite = CampaignInvite.find params[:campaign_invite_id]
  # end

  def search_key
    if params[:search_helper]
      @search_helper = SearchHelper.new(params.require(:search_helper).permit(:key, :item_type))
      return params[:search_helper][:key]
    end
  end
end
