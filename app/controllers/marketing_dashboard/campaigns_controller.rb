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
    @campaigns = @q.result.order('created_at DESC').paginate(paginate_params)
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
    authorize! :update, Campaign
    CampaignTarget.create(params.require(:campaign_target).permit(:target_type_text, :target_content).merge(:campaign_id => params[:id]))
    redirect_to targets_marketing_dashboard_campaign_path(:id => params[:id])
  end

  def stop
    authorize! :update, Campaign
    @campaign = Campaign.find params[:id]
    @campaign.finish("stop by admin")
    redirect_to :action => :index
  end

  def targets
    @campaign = Campaign.find params[:id]

    unmatched_kol_ids = @campaign.get_unmatched_kol_ids

    @kols = Kol.where(:id => @campaign.get_kol_ids).paginate(paginate_params)
    @unmatched_kols = Kol.where(:id => unmatched_kol_ids)

    @remove_kol_ids = @campaign.get_remove_kol_ids_by_target
    @black_list_ids = @campaign.get_black_list_kols
    @receive_campaign_kol_ids  = @campaign.get_remove_kol_ids_of_campaign_by_target
    @today_receive_three_times_kol_ids = @campaign.today_receive_three_times_kol_ids
    @title = "campaign: #{@campaign.name} 候选kols(总共 #{@kols.count}人)列表"
  end

  def add_example_screenshot
    @campaign = Campaign.find(params[:id])
  end

  def save_example_screenshot_and_remark
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(cpi_example_screenshot: params[:campaign][:cpi_example_screenshot],
      remark: params[:campaign][:remark])
    flash[:notice] = "保存成功"
    render :add_example_screenshot
  end

  def delete_target
    authorize! :update, Campaign
    @campaign_target = CampaignTarget.find params[:id]
    @campaign_target.destroy
    render :js => "alert('删除成功');$('#target_#{params[:id]}').remove()"
  end

  def recruit_targets
    @campaign = Campaign.find params[:id]
    @campaign_applies = @campaign.campaign_applies.order("created_at asc")
    @title = "符合要求的招募人数为 #{@campaign_applies.count}人"
  end

  def agree
    authorize! :update, Campaign
    @campaign = Campaign.find params[:campaign_id]
    @campaign.update(:status => :agreed)
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Agreed successfully!'}
      format.json { head :no_content }
    end
  end

  def reject
    authorize! :update, Campaign
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

    kol_id = params[:kol_id]
    campaign_id = params[:campaign_id]
    agree_reason = params[:agree_reason]
    operate = params[:operate]

    @campaign_apply = CampaignApply.find_by(campaign_id: params[:campaign_id], kol_id: params[:kol_id])

    if operate == 'agree'
      begin
        @campaign_apply.update_attributes(status: "platform_passed", agree_reason: agree_reason)
        return render json: {result: 'succeed', operate: operate, kol_id: kol_id}
      rescue
        return render json: {result: 'save status and reason failed'}
      end
    end
    if operate == 'cancel'
      begin
        @campaign_apply.update_attributes(status: "applying", agree_reason: nil)
        return render json: {result: 'succeed', operate: operate, kol_id: kol_id}
      rescue
        return render json: {result: 'save status and reason failed'}
      end
    end
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
end
