class MarketingDashboard::CampaignsController < MarketingDashboard::BaseController
  def index
    authorize! :read, Campaign

    @campaigns = if params[:kol_id]
                   Kol.find(params[:kol_id]).campaigns
                 elsif params[:user_id]
                   User.find(params[:user_id]).campaigns
                 else
                   Campaign.all
                 end.realable

    @q = @campaigns.ransack(params[:q])
    @campaigns = @q.result.order('created_at DESC')

    respond_to do |format|
      format.html do
        @campaigns = @campaigns.paginate(paginate_params)
        render 'index'
      end

      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"发布活动记录#{Time.now.strftime("%Y%m%d%H%M%S")}.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
        render 'index'
      end
    end
  end

  def pending
    @campaigns = Campaign.where(status: 'unexecute').realable
    @q = @campaigns.ransack(params[:q])
    @campaigns = @q.result.where("deadline >?", (Time.now-30.days)).order('created_at DESC').paginate(paginate_params)
    render 'index'
  end

  def asking
    @campaigns = Campaign.where(per_budget_type: "invite", status: 'unpay').realable
    @q = @campaigns.ransack(params[:q])
    @campaigns = @q.result.where("deadline >?", (Time.now-30.days)).order('created_at DESC').paginate(paginate_params)
    render 'index'
  end

  def push_all
    key = "campaign_id_#{params[:id]}_push_all"
    Rails.cache.write(key, 1, :expires_id => 10.days)
    CampaignWorker.perform_async params[:id], "push_all_kols"
    redirect_to request.referer
  end

  def agreed
    @campaigns = Campaign.agreed.realable
    @q = @campaigns.ransack(params[:q])
    @campaigns = @q.result.order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def rejected
    @campaigns = Campaign.where(status: 'rejected').realable
    @q = @campaigns.ransack(params[:q])
    @campaigns = @q.result.order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def testable
    @campaigns = Campaign.testable
    @q = @campaigns.ransack(params[:q])
    @campaigns = @q.result.order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def show
    authorize! :read, Campaign
    @campaign = Campaign.find params[:id]
  end

  def refresh_budget
    authorize! :update, Campaign

    @campaign = Campaign.find params[:id]

    if @campaign.budget == 0
      flash[:alert] = "活动(#{@campaign.id})总价格为０，请先修改KOL社交账号的价格，再编辑活动提交修改"
    elsif @campaign.update(need_pay_amount: @campaign.budget)
      flash[:notice] = "活动(#{@campaign.id})价格确认成功，可以联系用户支付了"
    else
      flash[:alert] = "活动(#{@campaign.id})价格确认失败，重试无效后请找技术支持"
    end
    redirect_to :action => :asking
  end

  def add_target
    authorize! :manage, Campaign
    CampaignTarget.create!(params.require(:campaign_target).permit(:target_type_text, :target_content).merge(:campaign_id => params[:id]))
    redirect_to targets_marketing_dashboard_campaign_path(:id => params[:id])
  end

  def stop
    authorize! :manage, Campaign
    @campaign = Campaign.find params[:id]
    @campaign.finish("expired; stop by admin")
    redirect_to :action => :index
  end

  def targets
    @campaign = Campaign.find params[:id]

    # unmatched_kol_ids = @campaign.get_unmatched_kol_ids

    @kols = Kol.where(:id => @campaign.get_kol_ids).paginate(paginate_params)
    # @unmatched_kols = Kol.where(:id => unmatched_kol_ids)

    # @remove_kol_ids = @campaign.get_remove_kol_ids_by_target
    # @black_list_ids = @campaign.get_black_list_kols
    # @receive_campaign_kol_ids  = @campaign.get_remove_kol_ids_of_campaign_by_target
    # @three_hours_had_receive_kol_ids = @campaign.three_hours_had_receive_kol_ids
    @title = "campaign: #{@campaign.name} 候选kols(总共 #{@kols.count}人)列表"
  end

  def add_example_screenshot
    @campaign = Campaign.find(params[:id])
  end

  def save_example_screenshot_and_remark
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(example_screenshot: params[:campaign][:example_screenshot],
      remark: params[:campaign][:remark])
    flash[:notice] = "保存成功"
    render :add_example_screenshot
  end

  def delete_target
    authorize! :manage, Campaign
    @campaign_target = CampaignTarget.find params[:id]
    @campaign_target.destroy
    render :js => "alert('删除成功');$('#target_#{params[:id]}').remove()"
  end

  def recruit_targets
    @campaign = Campaign.find params[:id]
    @campaign_applies = @campaign.campaign_applies
    @platform_passed_count = @campaign_applies.where(:status => 'platform_passed').count
    @brand_passed_count = @campaign_applies.where(:status => 'brand_passed').count

    @q = @campaign_applies.ransack(params[:q])
    @campaign_applies = @q.result.includes(:kol).order("created_at asc").page(params[:page]).per_page(50)

    @campaign_materials = @campaign.campaign_materials
  end


  def agree
    authorize! :manage, Campaign
    @campaign = Campaign.find_by :id => params[:campaign_id]
    if @campaign.status != 'unexecute'
      flash[:alert] = "该活动不是待审核状态，不能审核通过"
      redirect_to  pending_marketing_dashboard_campaigns_path
    else
      @campaign.update(:status => :agreed)
      if @campaign.user.mobile_number.present?
        SmsMessage.send_by_resource_to(@campaign.user, "您在Robin8发布的活动 #{@campaign.name} 已审核通过", @campaign, {mode: "general", admin: current_admin_user})
      end
      respond_to do |format|
        format.html { redirect_to :back, notice: 'Agreed successfully!'}
        format.json { head :no_content }
      end
    end
  end

  def reject
    authorize! :manage, Campaign
    @campaign = Campaign.find_by :id => params[:campaign_id]
    if @campaign.status != "unexecute"
      render :json => {:status => "error", :message => "活动不是待审核状态， 不能审核拒绝"} and return
    end

    if params[:invalid_reason].blank?
      render :json => {:status => "error", :message => "需要填写拒绝理由"} and return
    end

    @campaign.update(:status => :rejected, :invalid_reasons => params[:invalid_reason])

    render :json => {:status => "ok"}
  end


  def add_or_remove_recruit_kol
    authorize! :update, Campaign

    @operate = params[:operate]
    @campaign_apply = CampaignApply.find_by(campaign_id: params[:campaign_id], kol_id: params[:kol_id])

    if @operate == 'pass'
      status = 'platform_passed'
    elsif @operate == 'reject'
      status = 'platform_rejected'
    elsif @operate == 'option'
      status = 'option'
    elsif @operate == 'cancel'
      status = 'applying'
    end

    @campaign_apply.update_attributes(status: status, agree_reason: params[:agree_reason])
  end

  def batch_add_or_remove_recruit_kol
    authorize! :update, Campaign

    @operate = params[:operate]
    apply_ids =   params[:apply_ids].split(",")
    @campaign_applies = CampaignApply.where(id: apply_ids)
    return :js => "alert('你选择的申请中，有状态不在未审核中的')"  if @campaign_applies.size < apply_ids.size

    if @operate == 'pass'
      status = 'platform_passed'
    elsif @operate == 'reject'
      status = 'platform_rejected'
    elsif @operate == 'option'
      status = 'option'
    end
    @campaign_applies.update_all(:status => status)
  end

  def add_seller
    @campaign = Campaign.find(params[:id])
    if request.get?
      render :add_seller
    else
      @campaign.user.update(seller_id: params[:seller_id])
      redirect_to :back, notice: '添加成功'
    end
  end

  def push_record
    @push_records = CampaignPushRecord.where(campaign_id: params[:id]).paginate(paginate_params)

    @q = @push_records.ransack(params[:q])
    @push_records = @q.result.paginate(paginate_params)

    respond_to do |format|
      format.html do
        @push_records = CampaignPushRecord.where(campaign_id: params[:id]).paginate(paginate_params)
        render 'push_record'
      end

      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"活动推送记录#{Time.now.strftime("%Y%m%d%H%M%S")}.csv\""
        headers['Content-Type'] ||= 'text/csv; charset=utf-8'
        render 'push_record'
      end
    end

  end

  def set_auth_type
    @campaign = Campaign.find params[:id]
    if request.get?
    else
      @campaign.update_column(:wechat_auth_type, params[:campaign][:wechat_auth_type])
      redirect_to :action => :index
    end
  end

=begin
  def push_to_alizhongbao
    authorize! :update, Campaign
    @campaign = Campaign.find(params[:id])
    if @campaign.channel = nil
      @campaign.update_attributes!(channel:"azb")
      Partners::Alizhongbao.push_campaign(params[:id])
      flash[:notice] = "成功推送到阿里众包"
    elsif @campaign.channel = 'azb'
      flash[:notice] = "该活动早已推送过阿里众包了，长点心！"
    elsif @campaign.channel = 'wcs'
      @campaign.update_attributes!(channel:"all")
      Partners::Alizhongbao.push_campaign(params[:id])
      flash[:notice] = "该活动已经成功推送给所有合作伙伴了"
    elsif @campaign.channel = 'all'
      flash[:notice] = "该活动早已推送给所有合作伙伴了，长点心！"
    end
    redirect_to :action => :index
  end

  def push_to_wcs
    authorize! :update, Campaign
    @campaign = Campaign.find(params[:id])
    if @campaign.channel = nil
      @campaign.update_attributes!(channel:"wcs")
      flash[:notice] = "成功推送到微差事"
    elsif @campaign.channel = 'wcs'
      flash[:notice] = "该活动早已推送过微差事了，长点心！"
    elsif @campaign.channel = 'azb'
      @campaign.update_attributes!(channel:"all")
      flash[:notice] = "该活动已经成功推送给所有合作伙伴了"
    elsif @campaign.channel = 'all'
      flash[:notice] = "该活动早已推送给所有合作伙伴了，长点心！"
    end
    redirect_to :action => :index
  end

  def push_to_all_partners
    authorize! :update, Campaign
    @campaign = Campaign.find(params[:id])
    if @campaign.channel = 'all'
      flash[:notice] = "该活动早已推送给所有合作伙伴了，长点心"
    elsif @campaign.channel = 'wcs'
      @campaign.update_attributes!(channel:"all")
      Partners::Alizhongbao.push_campaign(params[:id])
      flash[:notice] = "该活动已经成功推送给所有合作伙伴了"
    elsif @campaign.channel = 'azb'
      @campaign.update_attributes!(channel:"all")
      flash[:notice] = "该活动已经成功推送给所有合作伙伴了"
    elsif @campaign.channel = nil
      @campaign.update_attributes!(channel:"all")
      Partners::Alizhongbao.push_campaign(params[:id])
      flash[:notice] = "该活动已经成功推送给所有合作伙伴了"
    end
    redirect_to :action => :index
  end
=end

  def push_to_partners
    authorize! :update, Campaign
    @campaign = Campaign.find(params[:id])
    channel = params[:channel]
    channel = "all"  unless @campaign.channel.blank?
    partner = case channel
              when "wcs"
                "微差事"
              when "azb"
                "阿里众包"
              when "all"
                "所有合作伙伴"
              end
    notice = "该活动已经成功推送给#{partner}了(ﾉ*･ω･)ﾉ"
    if !(@campaign.channel.in? ["azb" , "all"]) && channel.in? ["azb" , "all"]   
      resp = Partners::Alizhongbao.push_campaign(params[:id]) 
      notice = "该活动推送给阿里众包失败,请检查"  unless resp
    end
    @campaign.update_attributes!(channel: channel)
    flash[:notice] = notice 
    redirect_to :action => :index
  end

  def settle_for_partners
    SettlePartnerWorker.perform(params[:id] , params[:channel])
    flash[:notice] = "后台已经开始偷偷结算给阿里众包了哦(。・・)ノ"
    redirect_to :action => :index
  end
end
