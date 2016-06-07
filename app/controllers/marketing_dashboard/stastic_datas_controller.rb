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
  def day_statics
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

  # 统计在某时间段所有campaign
  def campaign_statics_in_time_range
    render 'campaign_statics_in_time_range' and return if request.method.eql? 'GET'
    start_time, end_time = params[:start_time], params[:end_time]
    @campaigns = Campaign.where(created_at: start_time.to_time..(end_time.to_time + 1.days)).where(status: :settled).order('created_at DESC').paginate(paginate_params)
    render 'campaign_statics_in_time_range', locals: {start_time: start_time, end_time: end_time}
  end

  def download_campaign_statics_in_time_range
    start_time, end_time = params[:start_time], params[:end_time]
    @campaigns = Campaign.where(created_at: start_time.to_time..(end_time.to_time + 1.days)).where(status: :settled)
    respond_to do |format|
      format.csv { send_data to_csv(@campaigns), filename: "campaign##{start_time}-#{end_time}.csv" }
    end
  end

  def kol_withdraw_statics_in_time_range
    render 'kol_withdraw_statics_in_time_range' and return if request.method.eql? 'GET'

    binding.pry
  end

  private
  def stastic_data_params
    params.require(:stastic_data).permit(:start_time, :end_time)
  end

  def to_csv(contents)
    Rails.logger.info '「我要开始导出数据了」'
    CSV.generate do |csv|
      csv << ['广告主id', '广告主名称', '活动id', '活动用户id', '活动总预算', '活动实际花费']
      contents.each do |item|
        spent = item.avail_click >= item.max_action ? item.max_action*item.per_action_budget : item.avail_click*item.per_action_budget
        csv << [item.user_id, item.user.name, item.id,item.user_id, item.budget, spent.round(2)] #数据内容
      end
    end
  end

end
