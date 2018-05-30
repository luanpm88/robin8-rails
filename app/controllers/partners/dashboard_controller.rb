class Partners::DashboardController < Partners::BaseController
 
	def index
  end

  # 7 days winner
  def chart1
    winner = Statistics::KolIncome.admintag(@admintag.tag).where(action_at: 7.days.ago.beginning_of_day..1.days.ago.end_of_day).order('day_of_income DESC').first

    respond_to do |format|
      format.html
      format.json {
        render json: (winner.to_hash rescue {})
      }
    end
  end

  # 30 days winner
  def chart2
    winner = Statistics::KolIncome.admintag(@admintag.tag).where(action_at: 31.days.ago.beginning_of_day..1.days.ago.end_of_day).order('day_of_income DESC').first
    
    respond_to do |format|
      format.html
      format.json {
        render json: (winner.to_hash rescue {})
      }
    end
  end

  #historical winner
  def chart3
    kol = Kol.joins(:admintags).where("admintags.tag=?", @admintag.tag).order('historical_income desc').first
    res = {}
    
    res = {
      name:       kol.name,
      income:     kol.historical_income,
      avatar_url: kol.avatar_url
    } if kol

    respond_to do |format|
      format.html
      format.json {
        render json: res
      }
    end
  end

  #7 days users Growth
  def chart4
    _date = Date.parse(params[:date])
    
    kols = Kol.joins(:admintags).where("admintags.tag=?", @admintag.tag).where(created_at:  _date.ago(6.days).beginning_of_day.._date.end_of_day).order("created_at asc")
    
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
    
    result = Statistics::CampaignInvite.find_campaign_invite(@admintag.tag, _date)
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
        render json: chartJson
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
        render json: chartJson
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
        render json: chartJson
      }
    end
  end

  def chart6
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
        render json: chartJson
      }
    end
  end

end

