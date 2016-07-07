class Weibo
  AccessTokenExpired = 7.days
  RefreshTokenExpired = 30.days
  # "https://api.weibo.com/oauth2/access_token?client_id=2851445977&client_secret=a30eb882d3ac6a9ee0f17f99cac89e70&redirect_uri=http://www.robin8.net&grant_type=refresh_token&refresh_token=2.00_Kqj9BJ34yGDbc3a74b1a3Q55dkD"
  def self.update_refresh_token(identity)
    if identity.provider == 'weibo' && identity.refresh_token && (identity.refresh_time && identity.refresh_time < Time.now + 30.days)
      url = "http://api.weibo.com/oauth2/access_token?client_id=1466698189&client_secret=1dca7fa45c0921a663e980a1c8c2f723&
      grant_type=refresh_token&redirect_uri=#{redirect_url}&refresh_token=#{identity.refresh_token}"
      res_json = RestClient.post url, {}   rescue {}
      return if res_json.blank? || res_json.size == 0
      identity.token = res_json['access_token']
      identity.access_token_refresh_time = Time.now
      identity.save
    end
  end


  def self.update_identity_to_db(identity)
    server = "https://api.weibo.com/2/users/show.json?access_token=#{identity.token}&uid=#{identity.uid}"
    res_json = RestClient.get(server)    rescue ""
    res = JSON.parse res_json        rescue {}
    Rails.logger.info "----update_identity_to_db"
    Rails.logger.info res
    return if res.blank? || res.size == 0
    identity.followers_count =  res['followers_count']
    identity.statuses_count = res['statuses_count']
    identity.verified = res['verified']
    identity.save
  end

  def self.update_identity_info(identity)
    return if identity.token.blank? || identity.uid.blank?
    Rails.logger.info "----update_identity_info"
    if identity.access_token_refresh_time && (identity.access_token_refresh_time <  Time.now + AccessTokenExpired)
      update_identity_to_db(identity)
    elsif identity.refresh_token && identity.refresh_time < Time.now + RefreshTokenExpired
      update_refresh_token(identity)
      update_identity_to_db(identity)
    else
      #can not refresh info
    end
  end


  def self.update_statuses(identity)
    return if identity.token.blank?
    # access_token 有效无需重新获取
    if identity.access_token_refresh_time && (identity.access_token_refresh_time <  Time.now + AccessTokenExpired)
      update_statuses_to_db(identity)
    elsif identity.refresh_token && identity.refresh_time < Time.now + RefreshTokenExpired
      update_refresh_token(identity)
      update_statuses_to_db(identity)
    end
  end

  def self.update_statuses_to_db(identity)
    server = "https://api.weibo.com/2/statuses/user_timeline.json?access_token=#{identity.token}"
    res_json = RestClient.get(server)    rescue ""
    res = JSON.parse res_json        rescue {}
    Rails.logger.info "----update_statuses_to_db"
    Rails.logger.info res
    return if res.blank? ||  res.size == 0
    KolStatus.add_status(identity, res["statuses"])
  end

  def self.get_status(identity)
    if identity.access_token_refresh_time && (identity.access_token_refresh_time <  Time.now + AccessTokenExpired)
      #nothing to do
    elsif identity.refresh_token && identity.refresh_time < Time.now + RefreshTokenExpired
      update_refresh_token(identity)
    else
      return [false, nil]
    end
    server = "https://api.weibo.com/2/statuses/user_timeline.json?access_token=#{identity.token}"
    res_json = RestClient.get(server)    rescue ""
    res = JSON.parse res_json        rescue {}
    statuses = []
    res["statuses"].each do |status|
      statuses << status['text']
    end
    return [true, statuses]
  end
end
