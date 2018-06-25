require "open-uri"
require 'json'

class TaobaoIps
  BaseURL = 'http://ip.taobao.com/service/getIpInfo.php?ip='

  def self.get_detail(ip)
    @ip   = ip
    @datas = JSON(open("#{BaseURL}#{@ip}").gets)
  end

end

