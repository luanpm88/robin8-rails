module Jd
  class Service
    #TODO  pagesize current is 1000. we must paginate   depend on hasMore column
    AppKey = Rails.application.secrets[:jd][:app_key]
    AppSecret = Rails.application.secrets[:jd][:app_secret]
    AccessToken = Rails.application.secrets[:jd][:access_token]
    UnionId = Rails.application.secrets[:jd][:union_id]
    WebId = Rails.application.secrets[:jd][:web_id]
    ServerUrl = Rails.application.secrets[:jd][:server_url]

    def self.get_code(sub_uniond_id = '123', material_url = 'http://item.m.jd.com/product/10125558111.html', channel = 'WL')
      info = {
        :promotionType => 7,
        :materialId => material_url,
        :unionId => UnionId,
        :subUnionId => sub_uniond_id,
        :channel => channel,
        :webId => WebId
      }
      res = send_request('jingdong.service.promotion.getcode', info)
      queryjs_result = res["jingdong_service_promotion_getcode_responce"]["queryjs_result"]
      url = JSON.parse(queryjs_result)["url"]
      return url
    end

    def self.get_batch_code(sub_union_id = '123', ids =[10125558111,1626258570], urls = ['http://item.m.jd.com/product/10125558111.html', 'http://item.m.jd.com/product/1626258570.html'] )
      info = {
        :id => ids.collect{|t| t.to_s}.join(","),
        :url => urls.join(","),
        :unionId => UnionId,
        :subUnionId => sub_union_id,
        :channel => 'WL',
        :webId => WebId
      }
      res = send_request('jingdong.service.promotion.batch.getcode', info)
      batch_result = res["jingdong_service_promotion_batch_getcode_responce"]["querybatch_result"]
      return JSON.parse(batch_result)["urlList"]
    end

    def self.get_goods_info(sku_ids = [10125558111,10000099135])
      info = {
        skuIds: sku_ids.collect{|t| t.to_s}.join(",")
      }
      response = send_request('jingdong.service.promotion.goodsInfo', info)
      res_json = response["jingdong_service_promotion_goodsInfo_responce"]["getpromotioninfo_result"]
      res = JSON.parse(res_json)
      puts res
      return res
    end

    def self.query_commisions(time =Time.now.strftime("%Y%m%d%H"), page_index = 1, page_size  = 1000)
      info = {
        :unionId => UnionId,
        :pageIndex => page_index,
        :pageSize => page_size,
        :time => time
      }
      res = send_request('jingdong.UnionOrderService.queryCommisions', info)
      queryorders_result = res["jingdong_UnionOrderService_queryCommisions_responce"]["querycommisions_result"]
      data = JSON.parse(queryorders_result)
      return data
    end

    def self.query_orders(time =Time.now.strftime("%Y%m%d%H"), page_index = 1, page_size  = 1000 )
      info = {
        :unionId => UnionId,
        :pageIndex => page_index,
        :pageSize => page_size,
        :time => time
      }
      res = send_request('jingdong.UnionOrderService.queryOrders', info)
      queryorders_result = res["jingdong_UnionOrderService_queryOrders_responce"]["queryorders_result"]
      data = JSON.parse(queryorders_result)
      return data
    end

    def self.send_request(method, params)
      Rails.logger.info "--------jd-----send_request: #{method}---params:#{params.inspect}"
      app_params = {
        :'360buy_param_json' => params.to_json,
        :access_token => AccessToken,
        :app_key => AppKey,
        :method => method,
        :v => '2.0',
        :timestamp => Time.now.strftime('%F %T')
      }
      app_params[:sign] = generate_sign(app_params)
      res = RestClient.get(ServerUrl, {:accept => :json, :params => app_params})
      res = JSON.parse res
      puts res
      Rails.logger.info "--------jd-----response: #{res.inspect}"
      return res
    end

    def self.generate_sign(params)
      Digest::MD5.hexdigest(AppSecret + params.sort.flatten.join + AppSecret).upcase
    end
  end
end

# Jd::Service.get_goodsInfo
