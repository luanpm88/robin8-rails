class MarketingDashboard::CampaignDataController < MarketingDashboard::BaseController
  def index
  	#按日期查询
  	@q = CampaignInvite.ransack(params[:q])
    # @campaign_invites = @q.result
    @week_num = 10
    @week_num = params[:q][:id_present].to_i if params[:q] && params[:q][:id_present]
    @week = ["本周"]
    @week_num.times do |t|
      @week.push("前第#{t}周") if t > 0
    end
    # @week_sum = CampaignInvite.where('created_at>?', Time.now.at_beginning_of_week).pluck(:kol_id).uniq.size
  end
end
