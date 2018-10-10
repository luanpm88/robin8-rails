class MarketingDashboard::TagsController < MarketingDashboard::BaseController

  def index
    @tags = Tag.all
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(params.require(:tag).permit(:name, :label))
    if @tag.save
      flash[:notice] = "创建成功"
      redirect_to action: :index
    else
      flash[:alert] = "创建失败"
      render 'new'
    end
  end

  def add_circle
    @circles = Circle.all
    @tag     = Tag.find params[:tag_id]

    render 'add_circle' and return if request.method.eql? 'GET'

    @tag.circles.delete_all

    @select_circles = Circle.where(id: params[:circle_ids])

    @tag.circles << @select_circles if @select_circles.present?

    redirect_to marketing_dashboard_tags_path
  end

end
