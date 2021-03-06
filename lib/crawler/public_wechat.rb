module Crawler
  class PublicWechat < Doc

    InfoUrl = "139.196.204.131:5001/search/v1.1/wechat"
    ArticleUrl = "139.196.204.131:5001/search/v1.1/wechat/articles"
    TimeOut = 20000
    def self.create_kol_info(social_account)
      return if social_account.uid.blank?
      params = {
        'filters': {
          'biz_code': social_account.uid,   # 指定公众号
          'kol_type': ['biz'],
        }
      }
      res = RestClient.post InfoUrl, params.to_json, :content_type => :json, :accept => :json, :timeout => TimeOut
      res = JSON.parse(res)
      puts "----"
      puts res
      articles_json = RestClient.get "#{ArticleUrl}?id=#{res['wechat'][0]['kol_id']}&from=0&size=3"  rescue nil
      return if articles_json.nil?
      JSON.parse(articles_json)['articles'].each do |article|
        KolShow.create(kol_id: social_account.kol_id, provider: 'public_wechat', title: article['title'], cover_url: article['msg_cdn_url'],
                       like_count: article['like_num'], read_count: article['read_num'],
                        publish_time: article['publish_date'], link: article['url'], desc: article['summary'])
      end
      # 更新头像 和关键字
      social_account.avatar_url = res['wechat'][0]['kol_avatar_url']  if res['wechat'][0]['kol_avatar_url'].present?
      social_account.username = res['wechat'][0]['kol_name']  if res['wechat'][0]['kol_name'].present?
      social_account.brief = res['wechat'][0]['kol_info']  if res['wechat'][0]['kol_info'].present?
      social_account.tags = Tag.where(:label => res['wechat'][0]['kol_category'])
      social_account.city =  res['wechat'][0]['kol_locations'].last
      social_account.save
      res['wechat'][0]['kol_keywords'].each do |keyword|
        KolKeyword.create!(kol_id: social_account.kol_id, social_account_id: social_account.id, :keyword => keyword)
      end
    end

  end
end
