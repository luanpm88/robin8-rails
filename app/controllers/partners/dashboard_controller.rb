class Partners::DashboardController < Partners::BaseController
 # before_filter except: [:index]
 #  before_action :set_locale
 #  before_action :set_link

 # layout 'gentelella'

	def index

  end

  # 7 days winner
  def chart1

    _start = Date.today - 7.days
    _end = Date.today - 1.days

    @day7q = Statistics::KolIncome.includes(:kol).joins(:kol).where("admintag=? ", @admintag.tag).where(action_at:  _start.beginning_of_day.._end.end_of_day).ransack(params[:q])
    @winner = @day7q.result.order('day_of_income DESC').limit(1);

    res = {record: {}, kol: {}}

    if !@winner.empty?
      res = {
        record: @winner.first,
        kol: @winner.first.kol.name,
        avatar_url: @winner.first.kol.avatar_url,
        updated_at: _end.end_of_day
      }
    end

    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

  # 30 days winner
  def chart2

    _start = Date.today - 31.days
    _end = Date.today - 1.days
    @day30q = Statistics::KolIncome.includes(:kol).joins(:kol).where("admintag=? ", @admintag.tag).where(action_at:  _start.beginning_of_day.._end.end_of_day).ransack(params[:q])
    @winner = @day30q.result.order('day_of_income DESC').limit(1);

    res = {record: {}, kol: {}}
    if !@winner.empty?

      res = {
        record: @winner.first,
        kol: @winner.first.kol.name,
        avatar_url: @winner.first.kol.avatar_url,
        updated_at: _end.end_of_day

      }
    end

    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

  #historical winner
  def chart3

    _end = Date.today - 1.days

    @q    = Kol.joins(:admintags).where("admintags.tag=? ", @admintag.tag).ransack(params[:q])
    @historical_kol = @q.result.order('historical_income desc').limit(1)

    res = {}
    if !@historical_kol.empty?

      res = {
        name: @historical_kol.first.name,
        income: @historical_kol.first.historical_income,
        avatar_url: @historical_kol.first.avatar_url,
        updated_at: _end.end_of_day
      }
    end

    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

  #7 days users Growth
  def chart4
    puts params[:date]
    _ago_day = 6
    _end = Date.parse(params[:date])
    
    @q = Kol.joins(:admintags).where("admintags.tag=? ", @admintag.tag).where(created_at:  _end.ago(_ago_day.days).beginning_of_day.._end.end_of_day).ransack(params[:q])
    @kols = @q.result.order("created_at asc")

    res = {}

    if !@kols.empty?
      @kols.each do |kk|

        curDate = DateTime.parse(kk.created_at.to_s).strftime('%d-%b').to_s

        if res[curDate] == nil
          res[curDate] = 0
        end
        res[curDate] += 1
      end
    end

    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

  def chart7
    result =
    Statistics::BrandSettledTakeBudget.where(:tag => @admintag.tag).limit(5).order("total_take_budget desc")
    labels = []
    data = []
    result.each do | c |

      user = User.find(c.user_id)
      labels.push user.smart_name
      data.push c.total_take_budget
    end

    chartJson = { "labels" => labels, "data" => data }

    respond_to do |format|
      format.html
      format.json {
        render :json => chartJson
      }
    end
  end


  def chart8
    
    result = Tag.group_by_tag( 5, @admintag.tag)
    labels = []
    data = []
    
    result.each do | c |

      labelKey = "tags.label."+ c.name
      labels.push t labelKey
      data.push c.percentage
    end

    chartJson = { "labels" => labels, "data" => data }

    respond_to do |format|
      format.html
      format.json {
        render :json => chartJson
      }
    end
  end

  def chart6
    #Tag.group_by_tag
    result = Tag.group_by_app_city( 5, @admintag.tag)
    labels = []
    data = []
    total = 0
    result.each do | c |

      labelKey = "cities.label."+ c.app_city
      labels.push t labelKey
      data.push c.percentage
      total = total + c.percentage
    end
    labels.push t "other.label.name"
    data.push 100 - total
    chartJson = { "labels" => labels, "data" => data }


    respond_to do |format|
      format.html
      format.json {
        render :json => chartJson
      }
    end
  end

  def chart5
    
    _end = Date.parse(params[:date])
    
    result = Statistics::CampaignInvite.find_campaign_invite(@admintag.tag, _end)
    labels = []
    data = []
    result.each do | c |
      labels.push DateTime.parse(c.data_date.to_s).strftime('%d-%b').to_s
      data.push c.total_activity_count
    end
    chartJson = { "labels" => labels, "data" => data }


    respond_to do |format|
      format.html
      format.json {
        ##   render json: Tag.group_by_tag( 5)}
        render :json => chartJson
        ##   :json=>@product
      }
    end
  end
end

