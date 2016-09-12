class MarketingDashboard::FeedbacksController < MarketingDashboard::BaseController
  def index
    authorize! :read, Feedback
    @kol = Kol.where(id: params[:kol_id]).take

    if @kol
      @feedbacks = @kol.feedbacks.order('created_at DESC').paginate(paginate_params)
      render :history
    else
      @feedbacks = Feedback.all.order('created_at DESC').paginate(paginate_params)
      render :index
    end
  end

  def show
    authorize! :read, Feedback
    @feedback = Feedback.find params[:id]
    @kol = @feedback.kol

  end

  def processed
    authorize! :update, Feedback
    @feedback = Feedback.find params[:id]
    if @feedback
      @feedback.update_column(:status, 'processed')
    end
    render :js => "$('#feedback_#{@feedback.id}').html('已处理');alert('设置成功');"
  end

  def reply
    authorize! :update, Feedback
    @feedback = Feedback.find params[:id]
    @kol = @feedback.kol
    if SmsMessage.send_by_resource_to(@kol, params[:content], @feedback, {mode: "feedback", admin: current_admin_user, remark: params[:remark]})
      render :json => {error: 0, msg: "回复完成"}
    else
      render :json => {error: 1, msg: "回复失败，请先重试"}
    end
  end
end
