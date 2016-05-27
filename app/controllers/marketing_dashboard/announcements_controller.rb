class MarketingDashboard::AnnouncementsController < MarketingDashboard::BaseController


  def index
    @announcements  = Announcement.order_by_position
  end

  def new
    @announcement = Announcement.new
  end

  def create
    params.permit!
    @announcement =  Announcement.new(params[:announcement])
    if @announcement.save
      redirect_to :action => :index
    end
  end

  def destroy
    @announcement = Announcement.find params[:id]
    @announcement.destroy
    redirect_to :action => :index
  end

  private

    def announcement_params
      params.require(:announcement).permit()
    end
end

