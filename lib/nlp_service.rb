class NlpService
  TimeOut = 200
  Service = "http://139.196.29.133:11000/nlp_service/analyze_content"
  def self.get_analyze_content(contents)
    # contents = ["首先受够了微信API种相关参数命名，可能微信比较喜欢配置而不是约定","申请过程复杂，各种证件，证书。基本和入党差不多了严格了。"]
    params = {:contents => contents}
    res = RestClient.post Service, params.to_json, :content_type => :json, :accept => :json, :timeout => TimeOut         rescue ""
    JSON.parse(res)
  end
end
