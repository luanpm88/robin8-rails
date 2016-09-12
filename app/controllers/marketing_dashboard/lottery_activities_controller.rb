class MarketingDashboard::LotteryActivitiesController < MarketingDashboard::BaseController

  def index
    authorize! :read, LotteryActivity
    if params[:status]
      @lottery_activities = LotteryActivity.where(status: params[:status])
    else
      @lottery_activities = LotteryActivity.all
    end

    @q = @lottery_activities.ransack(params[:q])
    @lottery_activities = @q.result.order('created_at DESC')
    @lottery_activities = @lottery_activities.paginate(paginate_params)
  end

  # def edit
  #   @lottery_activity = LotteryActivity.find(params[:id])
  # end

  # def update
  #   @lottery_activity = LotteryActivity.find(params[:id])

  #   if @lottery_activity.update(lottery_activity_params)
  #     redirect_to marketing_dashboard_lottery_activities_path
  #   else
  #     render 'edit'
  #   end
  # end

  def show
    authorize! :read, LotteryActivity
    @lottery_activity = LotteryActivity.find(params[:id])
  end

  def destroy
    authorize! :update, LotteryActivity
    @lottery_activity = LotteryActivity.find params[:id]
    @lottery_activity.destroy
    redirect_to action: :index
  end

  # def execute
  #   @lottery_activity = LotteryActivity.find params[:id]
  #   @lottery_activity.update_attribute :status, "executing"
  #   redirect_to marketing_dashboard_lottery_activities_path
  # end

  private

  def lottery_activity_params
    params.require(:lottery_activity).permit(:name, :description, :total_number)
  end
end
