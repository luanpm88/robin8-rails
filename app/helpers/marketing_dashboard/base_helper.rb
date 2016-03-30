module MarketingDashboard::BaseHelper
  def multi_send obj, list
    splited_list = list.split('.')
    @result = obj
    (splited_list.count > 0) ? (splited_list.each {|x| @result = parse_and_send(@result, x)}) : (@result = nil)
    @result
  end

  private
  def parse_and_send r, x
    if x.include? '_id'
      resource = x.sub '_id', ''
      id = r.send x
      link_to id, Rails.application.routes.url_helpers.send("marketing_dashboard_#{resource}_path", id)
    else
      r.send x
    end
  end
end
