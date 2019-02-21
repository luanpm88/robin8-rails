module BigV
  module Weibo

    def self.bind(kol_id, profile_id)
      url = "http://api_admin.robin8.net:8080/api/v1/r1/price/weibo/kol_bind/bind_kol?application_id=local-001&application_key=admin-001&kol_id=#{kol_id}&profile_id=#{profile_id}"

      res = RestClient.post(url, {}.to_json, :content_type => :json, :accept => :json, :timeout => 30) rescue ""
    end

    def self.search(profile_name, page_no=0)
      url = "http://api_prod.robin8.net:8080/api/v1/r1/price/weibo/price/kol_search_by_profile_name?application_id=local-001&application_key=vue-001&profile_name=#{profile_name}&page_no=#{page_no}&page_size=10"

      res = RestClient.get(url)
    end

   end
end
