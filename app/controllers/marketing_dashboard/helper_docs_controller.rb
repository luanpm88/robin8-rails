class MarketingDashboard::HelperDocsController < MarketingDashboard::BaseController
  def index
    @helper_docs = HelperDoc.all.order('sort_weight DESC').paginate(paginate_params)
  end

  def new
    @title = "新建问题"
    @helper_doc = HelperDoc.new
  end

  def create
    @helper_doc = HelperDoc.new(permit_params)
    if @helper_doc.save
      redirect_to marketing_dashboard_helper_docs_url
    else
      flash[:alert] = @helper_doc.errors.messages.values.flatten.join("\n")
      render :new
    end
  end

  def show
  end

  def edit
    @title = "编辑问题"
    @helper_doc = HelperDoc.find(params[:id])
  end

  def update
    @helper_doc = HelperDoc.find(params[:id])
    if @helper_doc.update_attributes(permit_params)
      redirect_to marketing_dashboard_helper_docs_url
    else
      flash[:alert] = @helper_doc.errors.messages.values.flatten.join("\n")
      render :edit
    end
  end

  def destroy
    @helper_doc = HelperDoc.find(params[:id])
    @helper_doc.delete
    flash[:notice] = "删除成功"
    redirect_to marketing_dashboard_helper_docs_url
  end

  private
  def permit_params
    params.require(:helper_tag).permit(:question, :answer, :doc_tag, :sort_weight)
  end
end