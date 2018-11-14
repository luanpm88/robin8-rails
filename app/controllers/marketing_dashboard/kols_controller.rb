class MarketingDashboard::KolsController < MarketingDashboard::BaseController
  before_action :set_kol, only: [:ban, :disban, :withdraw, :tracks]

  def index
    @kols = Kol.all
    load_kols
  end

  def banned
    @kols = Kol.where("forbid_campaign_time is not null")
    load_kols
  end

  def from_mcn
    @kols = Kol.where(kol_role: "mcn_big_v")
    load_kols
  end

  def from_app
    @kols = Kol.where(kol_role: "big_v")
    load_kols
  end

  def applying
    @kols = Kol.where(role_apply_status: "applying")
    load_kols
  end

  def passed
    @kols = Kol.where(role_apply_status: "passed")
    load_kols
  end

  def rejected
    @kols = Kol.where(role_apply_status: "rejected")
    load_kols
  end

  def show
    authorize! :read, Kol
    @kol = Kol.find params[:id]
  end

  def search
    authorize! :read, Kol
    render 'search' and return if request.method.eql? 'GET'

    search_by = "%#{params[:search_key]}%"



    @kols = Kol.where("id LIKE ? OR name LIKE ? OR mobile_number LIKE ? OR email LIKE ?", search_by, search_by, search_by, search_by).paginate(paginate_params)

    if params[:source_from] == "role_apply"
      render :role_apply_index and return
    end
    render 'index'
  end

  def ban
    authorize! :update, Kol
    render 'ban' # and return if request.method.eql? 'GET'

    # @kol.update(params.require(:kol).permit(:forbid_campaign_time, :kol_level))

    # respond_to do |format|
    #   format.html { redirect_to banned_marketing_dashboard_kols_path, notice: 'Ban successfully!' }
    #   format.json { head :no_content }
    # end
  end

  def disban
    authorize! :update, Kol
    @kol.update(forbid_campaign_time: Time.now)

    respond_to do |format|
      format.html { redirect_to banned_marketing_dashboard_kols_path, notice: 'Disban successfully!' }
      format.json { head :no_content }
    end
  end

  def withdraw
    authorize! :update, Kol
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

  def transaction
    @kol = Kol.find(params[:id])
    @transactions = Transaction.where(:account_type => 'Kol', :account_id => params[:id] )
    @q = @transactions.ransack(params[:q])
    @transactions = @q.result.order('id DESC').paginate(paginate_params)
  end

  def invites
    @kol = Kol.find(params[:id])
    @kols = @kol.children.paginate(paginate_params)
  end

  def edit
    authorize! :read, Kol
    @kol = Kol.find params[:id]
  end

  def edit_profile
    authorize! :read, Kol
    @kol = Kol.find params[:id]
  end

  def update_profile
    authorize! :update, Kol
    @kol = Kol.find params[:id]

    params[:kol][:mobile_number] = nil  if params[:kol][:mobile_number].blank?
    params[:kol][:email] = nil          if params[:kol][:email].blank?

    @kol.update_attributes(params.require(:kol).permit(:role_check_remark, :avatar, :mobile_number, :name, :job_info, :age, :gender, :role_apply_status, :desc, :memo, :show_count, :email))
    update_tag_ids
    update_keywords
    @kol.reload
    flash[:notice] = "保存成功"
    render :edit_profile
  end

  def update
    authorize! :update, Kol
    @kol = Kol.find params[:id]
    @kol.update_attributes(params.require(:kol).permit(:mobile_number, :name, :alipay_account, :alipay_name, :forbid_campaign_time, :kol_level))
    flash[:notice] = "保存成功"
    redirect_to marketing_dashboard_withdraws_path
  end

  def add_admintag
    render 'add_admintag' and return if request.method.eql? 'GET'

    @kol = Kol.find params[:kol_id]
    tag = params[:tag]

    # Add Admintag if it doesn't already exist. If it does already exist, then just reuse the original.
    if !Admintag.find_by(tag: tag).present?
      @kol.admintags.create(tag: tag)
    else
      @kol.admintags << Admintag.find_by(tag: tag)
    end

    redirect_to marketing_dashboard_kols_path
  end

  def remove_admintag
    # Remove Kol's relationship to Admintag
    @kol = Kol.find params[:kol_id]
    @admintag = Admintag.find params[:admintag_id]
    @kol.admintags.delete(@admintag)

    # If the Admintag no longer has any Kols, then destroy the Admintag also
    if !@admintag.kols.present?
      @admintag.destroy
    end

    redirect_to marketing_dashboard_kols_path
  end

  def campaign_compensation
    authorize! :update, Kol
    @kol = Kol.find params[:id]
    if request.get?
      @rejected_campaign_invite_arr = CampaignInvite.where(:kol_id => @kol.id, :status => 'rejected').order("id desc").includes(:campaign).collect{|t| [ "【campaign_id】: #{t.campaign_id}, 【campaign_name】: #{t.campaign.name}, 【credits】: #{t.avail_click * t.campaign.actual_per_action_budget}", t.id]}
    else
      campaign_invite = CampaignInvite.find params[:compensation_campaign_invite_id]   rescue nil
      campaign = campaign_invite.campaign                                              rescue nil
      if campaign_invite.blank?  || campaign.blank?
        flash[:notice] = '你尚未选择补偿的活动，或者补偿的活动未找到'
        redirect_to marketing_dashboard_kols_path
      else
        @kol.income(campaign_invite.avail_click * campaign.get_per_action_budget(false), 'campaign_compensation', campaign)
        Message.new_campaign_compensation(campaign_invite, campaign)
        flash[:notice] = '操作成功'
        redirect_to marketing_dashboard_kols_path
      end
    end
  end

  private
  def load_kols
    authorize! :read, Kol
    @kols = Campaign.find(params[:campaign_id]).kols if params[:campaign_id]

    @q    = @kols.includes(:admintags).ransack(params[:q])
    @kols = @q.result.order('id DESC')

    respond_to do |format|
      format.html do
        @kols = @kols.paginate(paginate_params)
        render 'index'
      end

      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"KOL记录#{Time.now.strftime("%Y%m%d%H%M%S")}.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
        render 'index'
      end
    end
  end

  def update_tag_ids
    old_tags = @kol.tags.map(&:id)
    now_tags = Array params[:kol][:tag_ids]
    KolTag.where(tag_id: old_tags-now_tags, kol_id: @kol.id).delete_all
    now_tags.each do |tag_id|
      KolTag.find_or_create_by(tag_id: tag_id, kol_id: @kol.id)
    end
  end

  def update_keywords
    weight = 100
     params[:kol][:key_word_names].gsub("，", ",").split(",").each_with_index do |word, index|
        word = word.strip
        unless KolKeyword.exists?(:kol_id => params[:id], :keyword => word)
          KolKeyword.create(:kol_id => params[:id], :keyword => word, :weight => weight - index)
        end
     end
  end

  def set_kol
    @kol = Kol.find params[:kol_id]
  end
end
