class IpScore < ActiveRecord::Base
  def self.fetch_ip_score(ip)
    Rails.cache.fetch "ip_score_#{ip}" do
      ip_score = IpScore.where(:ip => ip).first  || IpScore.create(:ip => ip, :score => get_score(ip))
      ip_score.score
    end
  end

  Server = "http://apis.baidu.com/rtbasia/non_human_traffic_screening_vp/nht_query"
  AppKey = '3f8e431c74da6f38dc0b2d0dac66b565'
  def self.get_score(ip)
    res_json = RestClient.get "#{Server}?ip=#{ip}", {:apikey => AppKey }
    res = JSON.parse res_json   rescue {}
    return res["data"]["score"]
  end
end
