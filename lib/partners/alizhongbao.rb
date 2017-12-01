module Partners
  module Alizhongbao
    URL    = "https://zbapi.taobao.com/gateway.do"
    APPID  = "10009"
    USERID = "28BF5CA24C219B59"

    def self.push_campaign(campaign_id)      # 把活动发布到 阿里众包
      campaign = Campaign.find(campaign_id)

      url = Rails.env.production? ? URL : "http://140.205.76.29/gateway.do"

      # body 就参考那个阿里众包api 文档 .docx
      params = {
        # API的固定参数，不同API的method参数会有区别
        method:       "alizhongbao.api.work.create",
        version:      "1.0",
        appId:        APPID,
        sign_type:    "RSA",
        notify_url:   "",
        charset:      "UTF-8",
        requestChannel: "1",
        timestamp:    Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        format:       "json",
        auth_token:   "",
        alizb_sdk:    "sdk-java-20161213",

        # 具体API的业务参数，如下是创建工作的参数
        userId:       USERID,
        name:         campaign.name,
        brief:        campaign.description,
        maxNum:       "1000",
        pay:          "0.6",
        catId:        "55",
        applyTaskUrl: "#{Rails.application.secrets[:domain]}/partner_campaign/campaign?id=#{campaign.id}&channel=azb",
        outId:        campaign.id.to_s,
        offlineTime:  campaign.deadline.strftime("%Y-%m-%d %H:%M:%S")
      }
      signature = sign(params)

      resp = HTTParty.post(url + params.to_query).parsed_response
    end

    def self.sign(params)
      # 把hash 变成类似url 参数
      string      = params.sort.reduce("") {|url, a| url+"#{a[0]}=#{a[1]}&" }[0..-2]

      # 获取secrets.yml 的 私钥private key
      private_key = OpenSSL::PKey::RSA.new(Rails.application.secrets[:partners][:alizhongbao][:private_key])
      signature   = private_key.sign(OpenSSL::Digest::SHA1.new, string)
      Base64.encode64(signature)
    end
  end
end
