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

  def new
    @lottery_activity = LotteryActivity.new
  end

  def edit
    @lottery_activity = LotteryActivity.find(params[:id])
  end

  def create
    @lottery_activity = LotteryActivity.new(lottery_activity_params)

    params[:lottery_activity][:posters].each do |picture|
      @lottery_activity.posters.build(name: picture)
    end

    params[:lottery_activity][:pictures].each do |picture|
      @lottery_activity.pictures.build(name: picture)
    end

    if @lottery_activity.save
      redirect_to marketing_dashboard_lottery_activity_path(@lottery_activity)
    else
      render 'new'
    end
  end

  def update
    @lottery_activity = LotteryActivity.find(params[:id])

    if params[:poster_id]
      @lottery_activity.posters.where(id: params[:poster_id]).take.tap do |picture|
        picture.destroy
      end
      return render 'edit'
    end

    if params[:picture_id]
      @lottery_activity.pictures.where(id: params[:picture_id]).take.tap do |picture|
        picture.destroy
      end
      return render 'edit'
    end

    if params[:lottery_activity][:posters].present?
      params[:lottery_activity][:posters].each do |picture|
        @lottery_activity.posters.build(name: picture)
      end
    end

    if params[:lottery_activity][:pictures].present?
      params[:lottery_activity][:pictures].each do |picture|
        @lottery_activity.pictures.build(name: picture)
      end
    end

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

  def execute
    @lottery_activity = LotteryActivity.find params[:id]
    @lottery_activity.update_attribute :status, "executing"
    redirect_to marketing_dashboard_lottery_activities_path
  end


  private

  def lottery_activity_params
    params.require(:lottery_activity).permit(:name, :description, :total_number)
  end
end
