class MarketingDashboard::Utilities::MarketingMessagesController < MarketingDashboard::BaseController
  def show
  end

  def create
    if SmsMessage.send_to(
      marketing_message_params[:mobile_number],
      marketing_message_params[:content], {
        mode: "manual",
        admin: current_admin_user,
        remark: marketing_message_params[:remark]
      })
      flash[:notice] = "短信发送成功！"
    else
      flash[:alert] = "短信发送失败，重试后问题还在的话，请联系技术支持"
    end

    redirect_to marketing_dashboard_utilities_marketing_message_path
  end

private

  def marketing_message_params
    params.require(:marketing_message).permit(:mobile_number, :content)
  end
end
