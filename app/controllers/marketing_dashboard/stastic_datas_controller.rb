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
    @total = Kol.where("mobile_number is not null").where("created_at > '#{day_count.days.ago}'").select("DATE(created_at) as created, count(*) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @wechat = Identity.where(:provider => 'wechat').where("created_at > '#{day_count.days.ago}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @weibo = Identity.where(:provider => 'weibo').where("created_at > '#{day_count.days.ago}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @qq = Identity.where(:provider => 'qq').where("created_at > '#{day_count.days.ago}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
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
    @value = KolInfluenceValue.where("created_at > '#{day_count.days.ago}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @article = ArticleAction.where(:forward => true).where("created_at > '#{day_count.days.ago}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @campaign = CampaignInvite.where("created_at > '#{day_count.days.ago}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @collect =  []
    today = Date.today
    day_count.times.each do |index|
      @collect << {:date => (today - index.days), :value => (@value[index].count rescue nil), :article => (@article[index].count rescue nil),
                   :campaign => (@campaign[index].count rescue nil)}
    end
  end

  private
  def stastic_data_params
    params.require(:stastic_data).permit(:start_time, :end_time)
  end
end
