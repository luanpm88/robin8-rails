class MarketingDashboard::TagsController < MarketingDashboard::BaseController

  def index
    @tags = Tag.all
    load_tags
  end

  def add_circle
    render 'add_circle' and return if request.method.eql? 'GET'

    @tag = Tag.find params[:tag_id]
    name = params[:name]
    lable = params[:lable]

    # Add Admintag if it doesn't already exist. If it does already exist, then just reuse the original.
    if !Circle.find_by(name: name).present?
      @tag.circles.create(name: name)
    else
      @tag.circles<< Circle.find_by(name: name)
    end

    redirect_to marketing_dashboard_tags_path
  end

  def remove_circle
    @tag = Tag.find params[:tag_id]
    @circle = Circle.find params[:circle_id]
    @tag.circles.delete(@circle)

    # If the Admintag no longer has any Kols, then destroy the Admintag also
    if !@circle.tags.present?
      @circle.destroy
    end

    redirect_to marketing_dashboard_tags_path
  end


  private
  def load_tags
    authorize! :read, Tag

    @q    = @tags.includes(:circles).ransack(params[:q])
    @tags = @q.result.order('id DESC')

    respond_to do |format|
      format.html do
        @tags = @tags.paginate(paginate_params)
        render 'index'
      end
    end
  end


end
