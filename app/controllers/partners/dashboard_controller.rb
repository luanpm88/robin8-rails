class Partners::DashboardController < Partners::BaseController
 # before_filter except: [:index]

	def index
    render 'index'
  end

  def chart8
    #Tag.group_by_tag
    result = Tag.group_by_tag( 5)
    labels = Array.new(result.size)
    data = Array.new(result.size)
    counter = 0
    result.each do | c |
      puts "Tag Name " + c.name
      puts "tag.label.name"
      labelKey = "tags.label."+ c.name
      labels[counter] = t labelKey
      data[counter] = c.counter
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
    result = Tag.group_by_app_city( 5)
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
    labels[counter] = "other.label.name"
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
end
