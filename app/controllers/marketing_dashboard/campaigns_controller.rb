class MarketingDashboard::CampaignsController < MarketingDashboard::BaseController
  def index
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
    @campaigns = @q.result.order('created_at DESC').paginate(paginate_params)

    render 'index'
  end

  def agreed
    @campaigns = Campaign.where.not(status: 'unexecute').realable
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
    @campaign = Campaign.find params[:id]
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

    @kols = Kol.where(:id => @campaign.get_kol_ids).paginate(paginate_params)
    @unmatched_kols = Kol.where(:id => unmatched_kol_ids)

    @remove_kol_ids = @campaign.get_remove_kol_ids_by_target
    @black_list_ids = @campaign.get_black_list_kols
    @receive_campaign_kol_ids  = @campaign.get_remove_kol_ids_of_campaign_by_target
    @today_receive_three_times_kol_ids = @campaign.today_receive_three_times_kol_ids
    @title = "campaign: #{@campaign.name} 候选kols(总共 #{@kols.count}人)列表"
  end

  def delete_target
    @campaign_target = CampaignTarget.find params[:id]
    @campaign_target.destroy
    render :js => "alert('删除成功');$('#target_#{params[:id]}').remove()"
  end

  def recruit_targets
    @campaign = Campaign.find params[:id]
    @campaign_applies = @campaign.campaign_applies
    @title = "符合要求的招募人数为 #{@campaign_applies.count}人"
  end

  def agree
    @campaign = Campaign.find params[:campaign_id]
    @campaign.update(:status => :agreed)
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Agreed successfully!'}
      format.json { head :no_content }
    end
  end

  def reject
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
end
