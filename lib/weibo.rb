class Weibo
  # "https://api.weibo.com/oauth2/access_token?client_id=2851445977&client_secret=a30eb882d3ac6a9ee0f17f99cac89e70&redirect_uri=http://www.robin8.net&grant_type=refresh_token&refresh_token=2.00_Kqj9BJ34yGDbc3a74b1a3Q55dkD"
  def self.update_refresh_token(identity)
    if identity.provider == 'weibo' && identity.refresh_token && (identity.refresh_time && identity.refresh_time < Time.now + 30.days)
      url = "http://api.weibo.com/oauth2/access_token?client_id=1466698189&client_secret=1dca7fa45c0921a663e980a1c8c2f723&
      grant_type=refresh_token&redirect_uri=#{redirect_url}&refresh_token=#{identity.refresh_token}"
      res_json = RestClient.post url, {}
      puts res_json
    end
  end

  def self.update_statuses(identity)
    server = "https://api.weibo.com/2/statuses/user_timeline.json?access_token=#{access_token}"
    res_json = RestClient.get(server)
    res = JSON.parse res_json        rescue nil
    return res
  end

  def self.update_identity_info(access_token)
    if access_token_refresh_time
    server = "https://api.weibo.com/2/users/show.json?access_token=#{access_token}"
    res_json = RestClient.get(server)
    res = JSON.parse res_json        rescue nil
    return res
  end
end
