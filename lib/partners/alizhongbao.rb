module Partners
  module Alizhongbao
    GATEWAY_URL = Rails.env.production? ? "https://zbapi.taobao.com/gateway.do" : "http://140.205.76.29/gateway.do"
    APPID       = "10009"
    USERID      = "28BF5CA24C219B59"
    BONUS       = 0.6

    def self.push_campaign(campaign_id)      # 把活动发布到 阿里众包
      campaign = Campaign.find(campaign_id)

      must_params = self.must_params("alizhongbao.api.work.create")

      brief = "薪酬计算规则：<br/>" +
        "根据分享到微信朋友圈获得好友的点击数量发放佣金 （点击单价*点击数量），每人只计算一次。<br/>" +
        "如：20个好友点击，获得20个有效点击的薪酬。任务薪酬为底薪+有效点击薪酬，点击薪酬将于验收后由阿里众包发放。
        有效点击数达到3个，获得底薪。<br/>" +
        "一 . 点击申领任务后，保存如图的二维码<br/>" +
        "二 . 打开微信扫一扫，选择相册中的截图<br/>" +
        "三 . 在页面点击完成任务，点击右上角分享到朋友圈<br/>" +
        "四 . 此时已经开始记录点击量，再次微信扫描截图即可查看点击量"

      app_params = {
        # 具体API的业务参数，如下是创建工作的参数
        "userId":       USERID,
        "name":         campaign.name,
        "brief":        brief,
        "maxNum":       "1000000",
        "pay":          (campaign.actual_per_action_budget*1000).to_i.to_s,
        "catId":        "76",
        "applyTaskUrl": "#{Rails.application.secrets[:domain]}/partner_campaign/campaign?id=#{campaign.id}&channel_id=azb",
        "outerId":      campaign.id.to_s,
        "offlineTime":  campaign.deadline.strftime("%Y-%m-%d %H:%M:%S")
      }

      options = self.http_options(app_params)

      signature           = sign(must_params.merge(app_params))
      must_params["sign"] = signature
      resp = HTTParty.post(GATEWAY_URL + "?" + must_params.to_query, options).parsed_response
      if (resp["success"] == true  rescue false)
        resp = JSON.parse(resp)
        campaign.update_attributes!(ali_task_id:      resp["result"]["taskId"],
                                    ali_task_type_id: resp["result"]["taskTypeId"],
                                    channel:          "azb")
        Rails.logger.partner_campaign.info "--alizhongbao: #{resp}"
        true
      else
        Rails.logger.partner_campaign.info "#{campaign.id} 分享给阿里众包失败"
        false
      end
    end

    #完成任务
    def self.completed_share(kol_id, campaign_id)
      kol         = Kol.find(kol_id)
      campaign    = Campaign.find(campaign_id)
      must_params = self.must_params("alizhongbao.api.task.finish")

      app_params = {
        # 具体API的业务参数，如下是完成并验收任务的参数
        "userId":        kol.cid,
        "taskId":        campaign.ali_task_id,
        "resultCode":    "1",
      }

      options = self.http_options(app_params)

      signature           = sign(must_params.merge(app_params))
      must_params["sign"] = signature

      resp = HTTParty.post(GATEWAY_URL + "?" + must_params.to_query, options).parsed_response
      resp = JSON.parse(resp)
      Rails.logger.partner_campaign.info "--azb_completed_share: #{resp}"
      resp
    end

    #结算campaign invite
    def self.settle_campaign_invite(campaign_invite_id)
      camp_inv = CampaignInvite.find(campaign_invite_id)

      must_params = self.must_params("alizhongbao.api.task.inspect")

      final_pay   = self.calculate_pay(camp_inv)

      inspect_result = if final_pay <= 0
                         "2"
                       elsif final_pay < camp_inv.campaign.actual_per_action_budget
                         "3"
                       elsif final_pay > camp_inv.campaign.actual_per_action_budget
                         "4"
                       elsif final_pay == camp_inv.campaign.actual_per_action_budget
                         "1"
                       end

      app_params = {
        # 具体API的业务参数，如下是完成并验收任务的参数
        "userId":        camp_inv.kol.cid,
        "taskId":        camp_inv.campaign.ali_task_id,
        "inspectResult": inspect_result,
        "inspectMemo":   "finish",
        "finalPay":      (final_pay*1000).to_i.to_s
      }

      options = self.http_options(app_params)

      signature           = sign(must_params.merge(app_params))
      must_params["sign"] = signature

      resp = HTTParty.post(GATEWAY_URL + "?" + must_params.to_query, options).parsed_response
      resp = JSON.parse(resp)
      Rails.logger.partner_campaign.info "--azb_settle_camp_inv: #{resp}"
      camp_inv.update_attributes!(partners_settle: final_pay)  if resp["result"]["msg"] = "质检成功"
      resp
    end

    #把活动结束掉
    def self.finish_campaign(campaign_id)
      campaign = Campaign.find(campaign_id)

      must_params = self.must_params("alizhongbao.api.work.operation")

      app_params = {
        # 具体API的业务参数，如下是完成并验收任务的参数
        taskTypeId: campaign.ali_task_type_id,
        operation:  "offline",
        reason:     "活动结束"
      }

      options = self.http_options(app_params)

      signature           = sign(must_params.merge(app_params))
      must_params["sign"] = signature

      resp = HTTParty.post(GATEWAY_URL + "?" + must_params.to_query, options).parsed_response
      Rails.logger.partner_campaign.info "--alizhongbao: #{resp}"
      resp = JSON.parse(resp)
    end

    private

    def self.http_options(app_params)
      {
        body:    app_params.delete_if{|k,v|v.blank?},
        headers: {'Content-Type' => 'application/x-www-form-urlencoded'}
      }
    end

    def self.must_params(method = nil)
      # Ali 每个接口调用必要的参数
      {
        "method":         method,
        "version":        "1.0",
        "appId":          APPID,
        "sign_type":      "RSA",
        "notify_url":     "",
        "charset":        "UTF-8",
        "requestChannel": "1",
        "timestamp":      Time.now.strftime("%Y-%m-%d %H:%M:%S"),
        "format":         "json",
        "auth_token":     "",
        "alizb_sdk":      "sdk-java-20161213"
      }
    end

    def self.get_sign_content(params)
      # 把hash 有空的删掉，变成类似url 参数
      params.sort.delete_if{|k,v|v.blank?}.reduce("") do |url, a|
        url+"#{a[0]}=#{a[1]}&"
      end[0..-2]
    end

    def self.sign(params)
      string      = get_sign_content(params)

      # 获取secrets.yml 的 私钥private key
      private_key = OpenSSL::PKey::RSA.new(Rails.application.secrets[:partners][:alizhongbao][:private_key])
      signature   = private_key.sign(OpenSSL::Digest::SHA1.new, string)
      Base64.encode64(signature).gsub("\n","")
    end

    def self.calculate_pay(camp_inv)
      # 多过三个的点击会多给0.6
      camp_inv.earn_money.to_d + (camp_inv.get_avail_click >= 3 ? BONUS : 0)
    end

    def self.import_dope_data(file_path)
      $redis.rpush("dope_sample_data", CSV.read(file_path))
    end

    def self.sample_data_left
      $redis.llen("dope_sample_data")
    end
  end
end
