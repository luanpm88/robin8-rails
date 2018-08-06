require 'csv'

class MarketingDashboard::StasticDatasController < MarketingDashboard::BaseController
  def index
    authorize! :read, StasticData

    @stastic_datas = StasticData.all.order('id DESC').paginate(paginate_params)
  end

  def new
    authorize! :read, StasticData
    @stastic_data = StasticData.new
  end

  def create
    authorize! :update, StasticData
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
    authorize! :read, StasticData
    @source_statics = StasticData.from_source
  end

  #只有在数据连续的时候  才可以，不然index值对应不正确
  def new_kol
    day_count = 5
    # _start = (day_count + 1).days.ago
    # @bind_mobiles = Kol.where("mobile_number is not null").where("created_at > '#{_start}'").select("DATE(created_at) as created, count(*) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    # @unbind_mobiles = Kol.where("mobile_number is null").where("created_at > '#{_start}'").select("DATE(created_at) as created, count(*) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    # @wechat = Identity.where(:provider => 'wechat').where("created_at > '#{_start}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    # @weibo = Identity.where(:provider => 'weibo').where("created_at > '#{_start}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    # @qq = Identity.where(:provider => 'qq').where("created_at > '#{_start}'").select("DATE(created_at) as created, count(distinct(kol_id)) as count").order("DATE(created_at) asc").group("DATE(created_at)")
    @collect =  []
    today = Date.today
    day_count.times.each do |index|
      date = today - index.days
      bind_mobiles = Kol.by_date(date).where("mobile_number is not null").count
      unbind_mobiles = Kol.by_date(date).where("mobile_number is null").count
      kol_ids = Kol.by_date(date).collect{|t| t.id}
      identitys = Identity.where(:kol_id => kol_ids).by_date(date).group("provider").size
      @collect << {:date => date,
                   :bind_mobiles => bind_mobiles,
                   :unbind_mobiles => unbind_mobiles,
                   :wechat => identitys['wechat'],
                   :weibo => identitys['weibo'],
                   :qq => identitys['qq']}
    end
  end

  #只有在数据连续的时候  才可以，不然index值对应不正确
  def day_statistics
    day_count = 5
    _start = (day_count + 1).days.ago
    @value = StasticData.day_statistics_value(_start)
    @article = StasticData.day_statistics_article(_start)
    @campaign = StasticData.day_statistics_invite(_start)
    @collect =  []
    today = Date.today
    day_count.times.each do |index|
      date = today - index.days
      @collect << {:date => date, :value => (@value.select{|t| t.count if t.created == date}[0].count rescue 0),
                   :article => (@article.select{|t| t.count if t.created == date}[0].count rescue 0),
                   :campaign => (@campaign.select{|t| t.count if t.created == date}[0].count rescue 0)}
    end
  end

  def kol_amount_statistics
  end

  def download_kol_amount_statistics
    file_path = File.expand_path("~/kol_amount_statistic/kol_amount.csv")
    send_file file_path, filename: "kol_amount##{Time.current.strftime("%Y-%m-%d")}.csv"
  end

  def user_recharge_statistics
  end

  def download_user_recharge_statistics
    @transactions = Transaction.where(account_type: 'User').where(direct: "income").where(subject: ["manual_recharge", "manaual_recharge", "alipay_recharge"]).order('created_at DESC')
    respond_to do |format|
      format.csv { send_data user_recharge_format_to_csv(@transactions), filename: "brand充值列表##{Time.current.strftime("%Y-%m-%d")}.csv" }
      format.xls { headers["Content-Disposition"] = "attachment; filename=\"brand充值列表##{Time.current.strftime("%Y-%m-%d")}.xls\"" }
    end
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

  def registered_invitations
    @invitations = RegisteredInvitation.order("created_at desc").page(params[:page])
    render 'registered_invitations'
  end

  def campaign_release_count
    @campaign_releases = Campaign.select("DATE(start_time) as date, count(*) as count, sum(budget) as budget").
      where("start_time >= '#{1.month.ago}'").where(:status => ['agreed', 'executing', 'executed', 'settled']).where("name not like '%测试%'").
      group("DATE(start_time)").
      order("DATE(start_time) desc")
  end

  def cooperation_data_reportes
    if params[:q].blank?
      params[:q] = {}
      params[:q][:admintags_tag_eq] = 'Geomatry'
    end
    @q    = Kol.includes(:admintags).ransack(params[:q])
    @kols = @q.result.order('id DESC')

    start_time = params[:start_time]
    deadline = params[:deadline]

    @campaigns = Campaign.all

    if start_time.present? && deadline.present?
      @campaigns = @campaigns.where("start_time >= ? and deadline <= ?", start_time, deadline)
    end

    @campaign_invites = CampaignInvite.where(kol_id: @kols)
    if start_time.present? && deadline.present?
      @campaign_invites = @campaign_invites.where("created_at >= ? and decline_date <= ?", start_time, deadline)
    end

    @transactoins_income = (Transaction.where(item: @campaigns).where(account: @kols).where(subject: 'campaign').map &:amount).sum
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

  def user_recharge_format_to_csv(items)
    CSV.generate do |csv|
      csv << ['广告主id', '广告主名称', '流水id' '充值方式', '充值金额', '充值税费(0.6%)', '充值时间']
      items.each do |item|
        if item.subject.in? ["manual_recharge", "manaual_recharge"]
          subject = "线下充值"
        elsif item.subject == "alipay_recharge"
          subject = "支付宝充值"
        end
        csv << [item.account.id, item.account.name, item.id, subject, item.credits.to_f, item.tax.to_f, item.created_at.strftime("%Y-%m-%d-%H:%M:%S")] #数据内容
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
