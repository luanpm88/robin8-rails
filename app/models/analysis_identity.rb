class AnalysisIdentity < ActiveRecord::Base
  WeiboRefreshTokenExpired = 30.days
  WeiboAccessTokenExpired = 30.days
  PublicWechatExpired = 1.days

  def valid_authorize?
    if self.provider == 'weibo'
      return self.authorize_time +  WeiboRefreshTokenExpired > Time.now
    else self.provider == 'public_wechat'
      return self.authorize_time + PublicWechatExpired > Time.now
    end
  end

  # 远程服务器
  ServerIp = 'http://139.196.36.27'
  ApiToken = 'b840fc02d524045429941cc15f59e41cb7be6c52'
  def get_weibo_info(info_type = {}, duration = nil )
    return if self.provider != 'weibo'
    params = {:api_token => ApiToken, :uid => self.uid, :access_token => self.access_token, :refresh_token => self.refresh_token,
              :authorized_at => self.authorize_time, :expires_at => self.authorize_time + WeiboAccessTokenExpired}
    params.merge!(info_type)
    if duration
      params['end_date'] = Date.today
      params['start_date'] = Date.today - duration.days  + 1.days  # 含end_date start_date
    end
    return RestClient.get("#{ServerIp}/weibo/report", {:params => params})
  end

  #for public wechat
  def newest_login
    return nil if self.provider != 'public_wechat'
    PublicWechatLogin.where(:username => self.name).order("id desc").first
  end

  #补全30天粉丝数
  def self.complete_follower_data(data = [],len)
    data_len = data.size
    if data_len < len
      today = Date.today
      (data_len..len).to_a.each do |i|
        data.insert(0,{"r_date" => today - i.days, 'number' => 0 })
      end
    end
    data
  end

  # 补全30天好友数
  def self.complete_sorted_friends(data = [],len)
    data_len = data.size
    if data_len < len
      today = Date.today
      (data_len..len).to_a.each do |i|
        data.insert(0,{"r_date" => today - i.days, 'total_number' => 0, 'verified_number' => 0, 'unverified_number' => 0 })
      end
    end
    data
  end

  def self.cal_follower_change(data, duration = 30)
    data_len = data.size
    return [0,0] if data_len.size == 0
    total_count = data.inject(0 ){|sum, t| sum + t['number']}
    avg_count =  total_count  / data_len
    return [total_count, avg_count]
  end

  def self.fake_list
    fake_list = []
    fake_list << AnalysisIdentity.new({"kol_id":nil,"id":10000001,"provider":"weibo","name":"Robin8示例数据","nick_name":nil,"avatar_url":"http://tva2.sinaimg.cn/crop.105.0.277.277.180/0065v6MHjw8f362ctlvo1j30dw0dwdh6.jpg","user_name":nil,"location":"上海,静安市","gender":"f","uid":"1340795523", "authorize_time": Time.now})
    fake_list << AnalysisIdentity.new({"kol_id":nil,"id":10000001,"provider":"public_wechat","name":"Robin8示例数据","nick_name": 'robin8china',"avatar_url":'http://tva2.sinaimg.cn/crop.105.0.277.277.180/0065v6MHjw8f362ctlvo1j30dw0dwdh6.jpg',"user_name":nil, "authorize_time": Time.now})
  end
end
