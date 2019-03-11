class MarketingDashboard::CampaignInvitesController < MarketingDashboard::BaseController

  def index
    authorize! :read, CampaignInvite

    conds = "screenshot is not NULL"
    conds << " and campaign_id=#{params[:campaign_id]}" if params[:campaign_id]

    @q = CampaignInvite.includes(:campaign).includes(kol: [:admintags]).where(conds).ransack(params[:q])

    @campaign_invites = @q.result.order('created_at DESC').paginate(paginate_params)

    respond_to do |format|
      format.html do
        render 'index'
      end

      # format.csv do
      #   headers['Content-Disposition'] = "attachment; filename=\"截图审核记录#{Time.now.strftime("%Y%m%d%H%M%S")}.csv\""
      #   headers['Content-Type'] ||= 'text/csv; charset=utf-8'
      #   render 'index'
      # end
    end
  end

  def pending
    conds = "screenshot is not NULL and img_status='pending'"
    conds << " and kol_id=#{params[:kol_id]}" if params[:kol_id]

    @q = CampaignInvite.includes(:campaign).includes(kol: [:admintags]).where(conds).ransack(params[:q])
    @campaign_invites = @q.result.order('created_at DESC').paginate(paginate_params)

    @batch_visible = true

    render :index
  end

  def passed
    @q = CampaignInvite.includes(:campaign).includes(kol: [:admintags]).where(img_status: 'passed').ransack(params[:q])
    @campaign_invites = @q.result.order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def rejected
    @q = CampaignInvite.includes(:campaign).includes(kol: [:admintags]).where(img_status: 'rejected').ransack(params[:q])
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

  private

  def search_key
    if params[:search_helper]
      @search_helper = SearchHelper.new(params.require(:search_helper).permit(:key, :item_type))
      return params[:search_helper][:key]
    end
  end
end
