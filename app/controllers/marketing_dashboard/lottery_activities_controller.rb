class MarketingDashboard::LotteryActivitiesController < MarketingDashboard::BaseController

  def index
    if params[:pending]
      @lottery_activities = LotteryActivity.where(status: 'pending').order('created_at DESC').paginate(paginate_params)
    elsif params[:executing]
      @lottery_activities = LotteryActivity.where(status: 'executing').order('created_at DESC').paginate(paginate_params)
    else
      @lottery_activities = LotteryActivity.order('created_at DESC').paginate(paginate_params)
    end
  end

  def edit
    @lottery_activity = LotteryActivity.find(params[:id])
  end

  def update
    @lottery_activity = LotteryActivity.find(params[:id])

    if @lottery_activity.update(lottery_activity_params)
      redirect_to marketing_dashboard_lottery_activities_path
    else
      render 'edit'
    end
  end

  def show
    @lottery_activity = LotteryActivity.find(params[:id])
  end

  def destroy
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
