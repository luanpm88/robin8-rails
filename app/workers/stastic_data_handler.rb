class StasticDataHandler
  include Sidekiq::Worker
  def perform stastic_data_id
    stastic_data = StasticData.find_by :id => stastic_data_id
    try_count = 1
    while true
      break if stastic_data
      sleep 5
      stastic_data = StasticData.find_by :id => stastic_data_id
    end

    stastic_data.total_kols_count = Kol.count
    stastic_data.incr_kols_count = Kol.where("created_at > ? and created_at < ?", stastic_data.start_time, stastic_data.end_time).count
    
    stastic_data.total_campaigns_count = Campaign.count
    stastic_data.incr_campaigns_count = Campaign.where("created_at > ? and created_at < ?", stastic_data.start_time, stastic_data.end_time).count

    stastic_data.weibo_kols_count = Kol.where(:provider => "weibo").count
    stastic_data.incr_weibo_kols_count = Kol.where(:provider => "weibo").where("created_at > ? and created_at < ?", stastic_data.start_time, stastic_data.end_time).count

    stastic_data.weixin_kols_count = Kol.where(:provider => "wechat").count
    stastic_data.incr_weixin_kols_count = Kol.where(:provider => "wechat").where("created_at > ? and created_at < ?", stastic_data.start_time, stastic_data.end_time).count    
    
    stastic_data.wx_third_kols_count = Kol.where(:provider => "wechat_third").count
    stastic_data.incr_wx_third_kols_count = Kol.where(:provider => "wechat_third").where("created_at > ? and created_at < ?", stastic_data.start_time, stastic_data.end_time).count    
    
    stastic_data.sign_up_kols_count = Kol.where(:provider => "signup").count
    stastic_data.incr_sign_up_kols_count = Kol.where(:provider => "signup").where("created_at > ? and created_at < ?", stastic_data.start_time, stastic_data.end_time).count    

    from_which_campaign_hash = {}
    Kol.where("created_at > ? and created_at < ?", stastic_data.start_time, stastic_data.end_time).each do |kol|
      from_which_campaign_hash[kol.from_which_campaign.to_s] = from_which_campaign_hash[kol.from_which_campaign.to_s].to_i + 1 
    end
    
    stastic_data.from_which_campaign = from_which_campaign_hash.to_a.map do |f| "(#{f[0]}: #{f[1]})" end
    stastic_data.is_dealed = true
    stastic_data.save
  end
end