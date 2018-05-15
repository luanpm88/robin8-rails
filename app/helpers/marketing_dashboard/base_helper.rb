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
    unless $redis.get("super_visitor_token")
      $redis.setex("super_visitor_token", 1.days.to_i, SecureRandom.hex)
    end
    $redis.get("super_visitor_token")
  end

  def link_to_switch_user_active(user, opts={})
    if user.is_active
      btn_txt = "设置为未激活"
      btn_clz = "btn-danger"
    else
      btn_txt = "设置为激活"
      btn_clz = "btn-success"
    end
    link_to btn_txt, active_marketing_dashboard_user_path(user), class: "btn #{btn_clz}", method: :put
  end

  def link_to_switch_user_live(user, opts={})
    if user.is_live
      btn_txt = "指定为实验数据"
      btn_clz = "btn-danger"
    else
      btn_txt = "指定为真实数据"
      btn_clz = "btn-success"
    end
    link_to btn_txt, live_marketing_dashboard_user_path(user), class: "btn #{btn_clz}", method: :put
  end

  def color_time(time)
    return unless time
    cls = Time.now > time ? "text-success" : "text-default"
    content_tag(:span, time.strftime("%Y-%m-%d %H:%M"), class: cls)
  end

  def format_hms(time)
    h = time / 3600
    m = (time - h * 3600) / 60
    s = (time - h * 3600) % 60

    "#{h}时#{m}分#{s}秒"
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
