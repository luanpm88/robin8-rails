require 'csv'

class MarketingDashboard::StasticDatasController < MarketingDashboard::BaseController
  def index
    @stastic_datas = StasticData.all.order('id DESC').paginate(paginate_params)
  end

  def new
    @stastic_data = StasticData.new
  end

  def create
    @stastic_data = StasticData.new stastic_data_params

    respond_to do |format|
      if @stastic_data.save
        format.html { redirect_to marketing_dashboard_stastic_datas_path, notice: 'Create new stastic data successfully!' }
      else
        format.html { }
      end
    end
  end

  def from_source
    @source_statics = StasticData.from_source
  end

  #只有在数据连续的时候  才可以，不然index值对应不正确
  def new_kol
    day_count = 5
    _start = (day_count + 1).days.ago
    @total = Kol.where("mobile_number is not null").where("created_at > '#{_start}'").select("DATE(created_at) as created, count(*) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @wechat = Identity.where(:provider => 'wechat').where("created_at > '#{_start}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @weibo = Identity.where(:provider => 'weibo').where("created_at > '#{_start}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @qq = Identity.where(:provider => 'qq').where("created_at > '#{_start}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @collect =  []
    today = Date.today
    day_count.times.each do |index|
      @collect << {:date => (today - index.days), :total => (@total[index].count rescue nil), :wechat => (@wechat[index].count rescue nil),
                   :weibo => (@weibo[index].count rescue nil), :qq => (@qq[index].count rescue nil)}
    end
  end

  #只有在数据连续的时候  才可以，不然index值对应不正确
  def day_statistics
    day_count = 5
    _start = (day_count + 1).days.ago
    @value = KolInfluenceValue.where("created_at > '#{_start}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @article = ArticleAction.where(:forward => true).where("created_at > '#{_start}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @campaign = CampaignInvite.where("created_at > '#{_start}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @collect =  []
    today = Date.today
    day_count.times.each do |index|
      @collect << {:date => (today - index.days), :value => (@value[index].count rescue nil), :article => (@article[index].count rescue nil),
                   :campaign => (@campaign[index].count rescue nil)}
    end
  end

  def kol_amount_statistics
  end

  def download_kol_amount_statistics
    file_path = File.expand_path("~/kol_amount_statistic/kol_amount.csv")
    send_file file_path, filename: "kol_amount##{Time.current.strftime("%Y-%m-%d")}.csv"
  end

  # 统计在某时间段所有campaign
  def campaign_statistics_in_time_range
    render 'campaign_statistics_in_time_range' and return if (request.method.eql? 'GET') && params[:page].blank?
    start_time, end_time = params[:start_time], params[:end_time]
    @campaigns = Campaign.where(created_at: start_time.to_time..(end_time.to_time + 1.days)).where(status: :settled).order('created_at DESC').paginate(paginate_params)
    render 'campaign_statistics_in_time_range', locals: {start_time: start_time, end_time: end_time}
  end

  def download_campaign_statistics_in_time_range
    start_time, end_time = params[:start_time], params[:end_time]
    @campaigns = Campaign.where(created_at: start_time.to_time..(end_time.to_time + 1.days)).where(status: :settled)
    respond_to do |format|
      format.csv { send_data campaign_format_to_csv(@campaigns), filename: "campaign##{start_time}-#{end_time}.csv" }
      format.xls { headers["Content-Disposition"] = "attachment; filename=\"campaign##{start_time}-#{end_time}.xls\"" }
    end
  end

  def kol_withdraw_statistics_in_time_range
    render 'kol_withdraw_statistics_in_time_range' and return if (request.method.eql? 'GET') && params[:page].blank?
    start_time, end_time = params[:start_time], params[:end_time]
    @withdraws = Withdraw.where(updated_at: start_time.to_time..(end_time.to_time + 1.days)).where(status: :paid).order('created_at DESC').paginate(paginate_params)
    render 'kol_withdraw_statistics_in_time_range', locals: {start_time: start_time, end_time: end_time}
  end

  def download_kol_withdraw_statistics_in_time_range
    start_time, end_time = params[:start_time], params[:end_time]
    @withdraws = Withdraw.where(updated_at: start_time.to_time..(end_time.to_time + 1.days)).where(status: :paid)
    respond_to do |format|
      format.csv { send_data withdraw_format_to_csv(@withdraws), filename: "withdraw##{start_time}-#{end_time}.csv" }
      format.xls { headers["Content-Disposition"] = "attachment; filename=\"withdraw##{start_time}-#{end_time}.xls\"" }
    end
  end

  private
  def stastic_data_params
    params.require(:stastic_data).permit(:start_time, :end_time)
  end

  def campaign_format_to_csv(items)
    CSV.generate do |csv|
      csv << ['广告主id', '广告主名称', '活动id', '活动用户id', '活动总预算', '活动实际花费']
      items.each do |item|
        spent = item.avail_click >= item.max_action ? item.max_action*item.per_action_budget : item.avail_click*item.per_action_budget
        csv << [item.user_id, item.user.name, item.id,item.user_id, item.budget, spent.round(2)] #数据内容
      end
    end
  end

  def withdraw_format_to_csv(items)
    CSV.generate do |csv|
      csv << ['id', 'kol id', '真实姓名', '提现金额', '收款渠道', '支付宝帐号', '银行名称', '银行卡号', '提现状态']
      items.each do |item|
        csv << [item.id, item.kol_id, item.real_name,item.credits, item.withdraw_type, item.alipay_no, item.bank_name, item.bank_no, item.status] #数据内容
      end
    end
  end

end
