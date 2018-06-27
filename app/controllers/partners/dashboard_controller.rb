class Partners::DashboardController < Partners::BaseController
 
	def index
  end
  
  def income_data
  _date = case params[:cur_tab]
          when "kol_7d"
            8.days.ago
          when "kol_30d"
            31.days.ago
          when "kol_all"
            Date.parse("1970-01-01")
          else
            2.days.ago
          end
    
    incomes = Statistics::KolIncome.find_incomes(@admintag.tag, _date.beginning_of_day, 1.days.ago.end_of_day)

    respond_to do |format|
      format.json {
        render json: incomes
      }
    end
  end
  
  #7 days users Growth
  def chart4
    _date = Date.parse(params[:date])
    
    kols = Kol.admintag(@admintag.tag).recent(_date.ago(6.days), _date).order("created_at asc")
    
    res = {}

    kols.each do |kk|
      curDate = kk.created_at.strftime('%d-%b')
      res[curDate] = 0 unless res[curDate]
      res[curDate] += 1
    end

    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

  def chart5
    _date = Date.parse(params[:date])
    res   = {labels: [], data: []}

    result = Statistics::CampaignInvite.find_campaign_invite(@admintag.tag, _date)
    
    result.each do | c |
      res[:labels] << c.data_date.strftime('%d-%b')
      res[:data]   << c.total_activity_count
    end

    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

  def chart6
    res, total = {labels: [], data: []}, 0
 
    Tag.group_by_app_city( 5, @admintag.tag).each do | c |
      res[:labels] << t("cities.label."+ c.app_city)
      res[:data]   << c.percentage

      total += c.percentage
    end

    res[:labels] << t("other.label.name")
    res[:data]   << 100 - total

    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

  def chart7
    res    = {labels: [], data: []}
    result = Statistics::BrandSettledTakeBudget.includes(:user).where(tag: @admintag.tag).limit(5).order("total_take_budget desc")
    
    result.each do | c |
      res[:labels] << c.user.try(:smart_name)
      res[:data] << c.total_take_budget
    end

    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end


  def chart8
    res = {labels: [], data: []}

    Tag.group_by_tag(5, @admintag.tag).each do | c |
      res[:labels] << t("tags.label."+ c.name)
      res[:data]   << c.percentage
    end

    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

end

