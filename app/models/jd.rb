require 'rubygems'
require "digest/md5"
require "yaml"
require "uri"
require "json"
require 'rest-client'

class Jd
  AppKey = 'AA2CCA7E09E01250E4DE8E1C125F313C'
  AppSecret = '1202eca77b0e4b6ea30bd321aa5a94fb'
  AccessToken = '4dee57fd-f68d-44fe-bc3f-7357786b2566'
  UnionId =  '1000073715'
  WebId = '429482272'
  ServiceUrl = "https://api.jd.com/routerjson"

  def self.get_code(material_id = 'http://item.jd.com/10006618123.html')
    buy_param = {
      :promotionType => 7,
      :materialId => material_id,
      :unionId => UnionId,
      :subUnionId => '12944',
      :channel => 'PC',
      :webId => WebId
    }
    res =  send_request('jingdong.service.promotion.getcode',buy_param)
    queryjs_result = res["jingdong_service_promotion_getcode_responce"]["queryjs_result"]
    url = JSON.parse(queryjs_result)["url"]
    puts url
  end

  def self.get_batch_code
    info = {
      :id => ['122','223'],
      :url => ['http://item.jd.com/10125558111.html', 'http://item.jd.com/10000099135.html'],
      :unionId => UnionId,
      :subUnionId => 'test',
      :channel => 'PC',
      :webId => WebId
    }
    send_request('jingdong.service.promotion.batch.getcode',info)
  end

  def self.get_goodsInfo
    info = {
      skuIds: '10125558111,10000099135'
    }
    send_request('jingdong.service.promotion.goodsInfo',info)
  end

  def self.query_commisions
    info = {
      :unionId => UnionId,
      :pageIndex => 1 ,
      :pageSize => 20,
      :time => Time.now.strftime("%Y%m%d%H")
    }
   send_request('jingdong.UnionOrderService.queryCommisions',info)
  end

  def self.query_orders
    info = {
      :unionId => UnionId,
      :pageIndex => 1 ,
      :pageSize => 20,
      :time => Time.now.strftime("%Y%m%d%H")
    }
    res = send_request('jingdong.UnionOrderService.queryOrders',info)
    queryorders_result = res["jingdong_UnionOrderService_queryOrders_responce"]["queryorders_result"]
    data = JSON.parse(queryorders_result)
    puts data
  end

  def self.send_request(method,params)
    app_params = {
      :'360buy_param_json' => params.to_json,
      :access_token => AccessToken,
      :app_key => AppKey,
      :method => method,
      :v => '2.0',
      :timestamp => Time.now.strftime('%F %T')
    }
    app_params[:sign]  = generate_sign(app_params)
    res = RestClient.get(ServiceUrl, {:accept => :json, :params => app_params})
    res = JSON.parse res
    puts res
    puts "-----"
    return res
  end

  def self.generate_sign(params)
    Digest::MD5.hexdigest(AppSecret + params.sort.flatten.join + AppSecret).upcase
  end

end
Jd.query_orders
