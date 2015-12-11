require 'json'

class ShortUrl
  cattr_accessor :request
  SinaServerUrl = 'http://api.t.sina.com.cn/short_url/shorten.json'
  # def self.get_request
  #   self.request ||= Mechanize.new
  # end

  #生成 短地址
  def self.convert(long_url)
    long_url = URI.encode long_url
    respond = RestClient.get SinaServerUrl,{:params => {source: "998511434", :url_long => long_url }}
    # dom = get_request.get(SinaServerUrl, {source: "998511434", :url_long => long_url })
    # data = JSON.parse(dom.body)
    data = JSON.parse respond
    data[0]['url_short']
  rescue
    puts $!.message
    long_url
  end
end
