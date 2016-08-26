class MarketingDashboard::FeedbacksController < MarketingDashboard::BaseController
  def index
    authorize! :read, Feedback
    @feedbacks = Feedback.all.order('created_at DESC').paginate(paginate_params)
  end

  def processed
    authorize! :update, Feedback
    @feedback = Feedback.find params[:id]
    if @feedback
      @feedback.update_column(:status, 'processed')
    end
    render :js => "$('#feedback_#{@feedback.id}').html('已处理');alert('设置成功');"
  end

end
