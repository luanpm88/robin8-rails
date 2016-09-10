class MarketingDashboard::LotteryExpressesController < MarketingDashboard::BaseController

  def index
    authorize! :read, LotteryActivity
    @q = LotteryActivity.ransack(params[:q])
    @lottery_activities = @q.result.where(status: "finished").order('draw_at DESC')
    @lottery_activities = @lottery_activities.paginate(paginate_params)
  end

  def edit
    authorize! :read, LotteryActivity
    @lottery_activity = LotteryActivity.find(params[:id])
  end

  def update
    authorize! :update, LotteryActivity
    @lottery_activity = LotteryActivity.find(params[:id])

    if @lottery_activity.update(lottery_activity_params)
      @lottery_activity.deliver
      @lottery_activity.update(delivered: true, delivered_at: Time.now)
      redirect_to marketing_dashboard_lottery_expresses_path
    else
      render 'edit'
    end
  end

  private

  def lottery_activity_params
    params.require(:lottery_activity).permit(:express_number, :express_name)
  end
end
