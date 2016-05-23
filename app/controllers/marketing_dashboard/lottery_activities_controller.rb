class MarketingDashboard::LotteryActivitiesController < MarketingDashboard::BaseController

  def index
    @lottery_activities = LotteryActivity.order('created_at DESC').paginate(paginate_params)
  end

  def new
    @lottery_activity = LotteryActivity.new
  end

  def create
    @lottery_activity = LotteryActivity.new(lottery_activity_params)
    params[:lottery_activity][:pictures].each do |picture|
      @lottery_activity.pictures.build(name: picture)
    end
    if @lottery_activity.save
      redirect_to new_pictures_marketing_dashboard_lottery_activity_path(id: @lottery_activity.id)
    else
      render 'new'
    end

  end

  def destroy
    @lottery_activity = LotteryActivity.find params[:id]
    @lottery_activity.destroy
    redirect_to action: :index
  end

  def new_pictures

  end

  def create_pictures

  end

  private

  def lottery_activity_params
    params.require(:lottery_activity).permit(:name, :description, :total_number)
  end
end
