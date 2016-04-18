module MarketingDashboard::BaseHelper
  def multi_send obj, list
    splited_list = list.split('.')
    @result = obj
    (splited_list.count > 0) ? (splited_list.each {|x| @result = parse_and_send(@result, x)}) : (@result = nil)
    @result
  end

  def sensitivity_list
    ['encrypted_password', 'reset_password_token', 'reset_password_token_at', 'remeber_created_at', 'confirmation_token', 'reset_password_sent_at', 'remember_created_at', 'unconfirmed_email']
  end

  def get_super_visitor_token
    unless Rails.cache.fetch("super_visitor_token")
      Rails.cache.write("super_visitor_token", SecureRandom.hex, :expire_in => 1.days)
    end
    Rails.cache.fetch("super_visitor_token")
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
