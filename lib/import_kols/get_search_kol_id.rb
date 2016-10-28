module ImportKols
  class GetSearchKolId
    def self.get_weibo_kol_ids
      SocialAccount.where(:provider => 'weibo').each do |social_account|
        social_account.update_column(:search_kol_id, social_account.uid)
      end
    end

    SearchApiUrl = "http://139.196.204.131:5001/search/v1.1/wechat"
    TimeOut = 10
    def self.get_public_wechat_kol_ids(term = nil)
      SocialAccount.where(:provider => 'public_wechat').where("uid is not null or username is not null").each do |social_account|
        term = social_account[:uid] || social_account[:username]
        params = {'from': 0, 'size': 10, 'term': term, 'filter': {'kol_type': ['biz']}}
        res = RestClient.post SearchApiUrl, params.to_json, :content_type => :json, :accept => :json, :timeout => TimeOut
        res = JSON.parse res rescue {}
        res["wechat"].each do |wechat|
          if wechat['biz_code'] == term || wechat['biz_name'] == term
            social_account.update_column(:search_kol_id, wechat['kol_id'])
            break
          end
        end
      end
    end
  end
end
