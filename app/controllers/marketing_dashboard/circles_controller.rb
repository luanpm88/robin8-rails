class MarketingDashboard::CirclesController < MarketingDashboard::BaseController

  def index
    @circles = Circle.all
  end

  def new 
    @circle = Circle.new
  end

  def create 
    @circle = Circle.new(params.require(:circle).permit(:name, :label))
    if @circle.save
      flash[:notice] = "创建成功"
      redirect_to action: :index
    else
      flash[:alert] = "创建失败"
      render 'new'
    end
  end

  def add_tag
    @tags   = Tag.all
    @circle = Circle.find params[:circle_id]

    render 'add_tag' and return if request.method.eql? 'GET'

    @circle.tags.delete_all

    @select_tags = Tag.where(id: params[:tag_ids])

    @circle.tags << @select_tags if @select_tags.present?

    redirect_to marketing_dashboard_circles_path
  end

end

