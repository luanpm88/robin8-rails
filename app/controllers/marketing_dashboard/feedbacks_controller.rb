class MarketingDashboard::FeedbacksController < MarketingDashboard::BaseController
  def index
    @feedbacks = Feedback.all.order('created_at DESC').paginate(paginate_params)
  end
end
