class MarketingDashboard::AnnouncementsController < MarketingDashboard::BaseController


  def index
    authorize! :read, Announcement
    @announcements  = Announcement.order_by_position
  end

  def new
    authorize! :read, Announcement
    @announcement = Announcement.new
  end

  def create
    authorize! :update, Announcement
    params.permit!
    @announcement =  Announcement.new(params[:announcement])
    if @announcement.save
      redirect_to :action => :index
    end
  end

  def destroy
    authorize! :update, Announcement
    @announcement = Announcement.find params[:id]
    @announcement.destroy
    redirect_to :action => :index
  end

  private

    def announcement_params
      params.require(:announcement).permit()
    end
end
