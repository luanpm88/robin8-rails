class MarketingDashboard::KolAnnouncementsController < MarketingDashboard::BaseController


  def index
    @kol_announcements  = KolAnnouncement.order_by_position
  end

  def new
    @kol_announcement = KolAnnouncement.new
  end

  def create
    params.permit!
    @kol_announcement =  KolAnnouncement.new(params[:kol_announcement])
    if @kol_announcement.save
      redirect_to :action => :index
    end
  end

  def destroy
    @kol_announcement = KolAnnouncement.find params[:id]
    @kol_announcement.destroy
    redirect_to :action => :index
  end

  def switch
    @kol_announcement = KolAnnouncement.find params[:id]
    @kol_announcement.update_column(:enable, !@kol_announcement.enable)
    redirect_to :action => :index
  end

end

