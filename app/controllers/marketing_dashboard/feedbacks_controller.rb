class MarketingDashboard::FeedbacksController < MarketingDashboard::BaseController
  def index
    @feedbacks = Feedback.all.paginate(:page => 1, :per_page => 20)
  end
end
