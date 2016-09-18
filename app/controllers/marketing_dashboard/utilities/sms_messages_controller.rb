class MarketingDashboard::Utilities::SmsMessagesController < MarketingDashboard::BaseController
  def index
    @q = SmsMessage.all.ransack(params[:q])
    @sms_messages = @q.result.order("created_at DESC").paginate(paginate_params)
  end

  def show
    @sms_message = SmsMessage.find(params[:id])
  end
end
