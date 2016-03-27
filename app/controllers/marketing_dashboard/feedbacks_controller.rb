class MarketingDashboard::FeedbacksController < MarketingDashboard::BaseController
  def index
    @feedbacks = Feedback.all.paginate(paginate_params)
  end
end
