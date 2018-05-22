class Partners::DashboardController < Partners::BaseController
 # before_filter except: [:index]
 #  before_action :set_locale
 #  before_action :set_link

 # layout 'gentelella'

	def index

    render 'index'
  end

  # 7 days winner
  def chart1

    _start = Date.today - 7.days
    _end = Date.today - 1.days

    @day7q = KolIncomeActivities.includes(:kol).joins(:kol).where("admintag=? ", @admintag.tag).where(action_at:  _start.beginning_of_day.._end.end_of_day).ransack(params[:q])
    @res = @day7q.result.order('day_of_income DESC').limit(1);

    res = {record: {}, kol: {}}
    if @res.first != nil
      puts "empty!!!!!!!!!!!!!!=================="
      res = {
        record: @res.first,
        kol: @res.first.kol.name,
        avatar_url: @res.first.kol.avatar_url,
        updated_at: _end.end_of_day
      }
    end
    puts @res.first
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
    @day30q = KolIncomeActivities.includes(:kol).joins(:kol).where("admintag=? ", @admintag.tag).where(action_at:  _start.beginning_of_day.._end.end_of_day).ransack(params[:q])
    @res = @day30q.result.order('day_of_income DESC').limit(1);
    
    res = {record: {}, kol: {}}
    if @res.first != nil
      puts "empty!!!!!!!!!!!!!!=================="
      res = {
        record: @res.first,
        kol: @res.first.kol.name,
        avatar_url: @res.first.kol.avatar_url,
        updated_at: _end.end_of_day

      }
    end
    puts @res.first
    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

  #historical winner
  def chart3

    #KolIncomeActivities.job_for_kol_dashboard_income_data(Date.today - 2.days)
    _end = Date.today - 1.days

    @q    = Kol.joins(:admintags).where("admintags.tag=? ", @admintag.tag).ransack(params[:q])
    @historical_kol = @q.result.order('historical_income desc').limit(1)

    res = {}
    if @historical_kol.first != nil
      puts "not empty!!!!!!!!!!!!!!=================="
      res = {
        name: @historical_kol.first.name,
        income: @historical_kol.first.historical_income,
        avatar_url: @historical_kol.first.avatar_url,
        updated_at: _end.end_of_day
      }
    end
    puts @historical_kol.first.id
    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

  #7 days users incre
  def chart4

    _start = Date.today - 310.days # FIXME should change to 7 days
    _end = Date.today - 1.days

    @q = Kol.joins(:admintags).where("admintags.tag=? ", @admintag.tag).where(created_at:  _start.beginning_of_day.._end.end_of_day).ransack(params[:q])
    @kol = @q.result.order("created_at asc")

    res = {}
    
    if @kol.first != nil
      puts "not empty!!!!!!!!!!!!!!=================="
      @kol.each do |kk|
        dd = Date.parse kk.created_at.to_s
        curDate = dd.month.to_s + "-" + dd.year.to_s
        
        puts dd.month.to_s + "-" + dd.year.to_s
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
    Statistics::StatBrandSettledTakeBudget.where(:tag => @admintag.tag).limit(5).order("total_take_budget desc")
    labels = Array.new(result.size)
    data = Array.new(result.size)
    counter = 0
    result.each do | c |
      puts "Tag Name " + c.tag
      user = User.find(c.user_id)

      labels[counter] = user.smart_name
      #  data[counter] = c.counter
      data[counter] = c.total_take_budget
      counter = counter + 1
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
  

  def chart8
    #Tag.group_by_tag
    result = Tag.group_by_tag( 5, @admintag.tag)
    labels = Array.new(result.size)
    data = Array.new(result.size)
    counter = 0
    result.each do | c |
      puts "Tag Name " + c.name
      puts "tag.label.name"
      labelKey = "tags.label."+ c.name
      labels[counter] = t labelKey
    #  data[counter] = c.counter
      data[counter] = c.percentage
      counter = counter + 1
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

  def chart6
    #Tag.group_by_tag
    result = Tag.group_by_app_city( 5, @admintag.tag)
    labels = Array.new(result.size)
    data = Array.new(result.size)
    counter = 0
    total = 0;
    result.each do | c |
      puts "App City Name " + c.app_city
      labelKey = "cities.label."+ c.app_city
      labels[counter] = t labelKey
      data[counter] = c.percentage
      total = total + c.percentage
      counter = counter + 1
    end
    labels[counter] = t "other.label.name"
    data[counter] = 100 - total
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

  def chart5
    #Tag.group_by_tag
    result = Statistics::StatCampaignInvite.find_campaign_invite(@admintag.tag, '2017-09-18')
    labels = Array.new(result.size)
    data = Array.new(result.size)
    counter = 0
    total = 0;
    result.each do | c |
      puts "Data Date " + c.data_date.to_s + " count " + c.total_activity_count.to_s
      labels[counter] = c.data_date
      data[counter] = c.total_activity_count
      counter = counter + 1
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

