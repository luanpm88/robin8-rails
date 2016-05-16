require 'rubygems'
require 'typhoeus'

module Weixin
  class PublicLogin
    UserAgent =  "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5"
    BaseUrl = "https://mp.weixin.qq.com/cgi-bin/login?lang=zh_CN"

    def  self.login_with_qrcode(username = 'huxiaolong100@126.com' , password = '123qweQWE')
      res, cookies, redirect_url = login_with_account(username, password)       # res1 正确返回  res, cookies, redirect_url
      return res if res[0] == 'error'
      res, ticket = get_ticker(cookies, redirect_url)
      return res if res[0] == 'error'
    end


    def self.login_with_account(username, password, code = nil)
      params = {:username => username, :pwd =>  Digest::MD5.hexdigest(password)}
      params.merge({:imgcode => code})    if code.present?
      request = Typhoeus.post(BaseUrl, followlocation: true, verbose: true,
                               :headers => {:user_agent => UserAgent,
                                            :referer => "https://mp.weixin.qq.com/",
                                            "Upgrade-Insecure-Requests" => 1
                               },
                               :params =>  params
                 )
      response = JSON.parse request.response_body   rescue {}
      cookies = ""
      if response["base_resp"].present? || response["base_resp"]["ret"] == '0'
        request.response_headers.split("\n").each do |res_head|
          res = res_head.split(":")
          cookies << "#{res[1].split(";")[0]};"   if res[0].eql? "Set-Cookie"
        end
        redirect_url = "https://mp.weixin.qq.com/" + response["redirect_url"]
        return [['success'], cookies , redirect_url]
      elsif response["base_resp"].present? || response["base_resp"]["ret"] == '200027'
        return [['error', 'verify_code']]
      else
        return [['error', 'account_wrong']]
      end
    end

    def verify_code_url(username)
      "https://mp.weixin.qq.com/cgi-bin/verifycode?username=#{username}&r=#{Time.now.to_i}"
    end

    def self.get_ticker(cookies, redirect_url)
      assistant_res = Typhoeus.post("https://mp.weixin.qq.com/misc/safeassistant?1=1&token=&lang=zh_CN",
                                    :headers => {
                                       :user_agent => UserAgent,
                                       'X-Requested-With' => 'XMLHttpRequest',
                                       :referer => redirect_url,
                                       :Cookie => cookies
                                     },
                                    :body => "action=get_ticket&auth=ticket"
      )
      response = JSON.parse assistant_res  rescue {}
      if response["base_resp"] && response["base_resp"]["ret"] == '0'
         return ['success', response["base_resp"]["ticket"]]
      else
        return [['error', 'request_wrong']]
      end
    end

    def self.get_appid(cookies,redirect_url)
      url = "https://res.wx.qq.com/c/=/mpres/zh_CN/htmledition/js/safe/safe_check2a92e6.js,/mpres/zh_CN/htmledition/js/common/wx/Step218877.js,/mpres/zh_CN/htmledition/js/safe/Scan2d3016.js,/mpres/zh_CN/htmledition/js/user/validate_wx2d3016.js"
      assistant_res = Typhoeus.post(url,
                                    :headers => {
                                      :user_agent => UserAgent,
                                      'X-Requested-With' => 'XMLHttpRequest',
                                      :referer => redirect_url,
                                      :Cookie => cookies
                                    },
                                    :body => "action=get_ticket&auth=ticket"
      )

    end

    # #获取ticke
    # def self.get_ticker(cookies, redirect_url)
    #   body = "token=&lang=zh_CN&f=json&ajax=1&random=0.7635565652589176&appid=wx3a432d2dbe2442ce&scope=snsapi_contact&state=0&redirect_uri=https%3A%2F%2Fmp.weixin.qq.com&login_type=safe_center&type=json&ticket=#{(JSON.parse ssistant_response.response_body)['ticket']}"
    #   safeqrconnect_req = Typhoeus.post("https://mp.weixin.qq.com/safe/safeqrconnect?1=1&token=&lang=zh_CN",
    #                                      :headers => {:user_agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5",
    #                                                   'X-Requested-With' => 'XMLHttpRequest',
    #                                                   'Content-Type'=> "application/x-www-form-urlencoded",
    #                                                   :referer => url,
    #                                                   :Cookie => headers["Cookie"]
    #                                                  },
    #                                      :body => body
    #   )
    #
    #   puts "获取 appid #{safeqrconnect_response.response_body}"
    # end
  end
end
