class MarketingDashboard::CirclesController < MarketingDashboard::BaseController

  def index
    @circles = Circle.all
    load_circle
  end

  def add_tag
    render 'add_tag' and return if request.method.eql? 'GET'

    @circle = Circle.find params[:circle_id]
    name = params[:name]
    lable = params[:lable]

    # Add Admintag if it doesn't already exist. If it does already exist, then just reuse the original.
    if !Tag.find_by(name: name).present?
      @circle.tags.create(name: name)
    else
      @circle.tags<< Tag.find_by(name: name)
    end

    redirect_to marketing_dashboard_circles_path
  end

  def remove_tag
    @tag = Tag.find params[:tag_id]
    @circle = Circle.find params[:circle_id]
    @circle.tags.delete(@tag)

    # If the Admintag no longer has any Kols, then destroy the Admintag also
    if !@tag.circles.present?
      @tag.destroy
    end

    redirect_to marketing_dashboard_circles_path
  end


  private
  def load_circle
    authorize! :read, Circle

    @q    = @circles.includes(:tags).ransack(params[:q])
    @circles = @q.result.order('id DESC')

    respond_to do |format|
      format.html do
        @circles = @circles.paginate(paginate_params)
        render 'index'
      end
    end
  end


end

