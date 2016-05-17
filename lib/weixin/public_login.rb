require 'rubygems'
require 'typhoeus'

module Weixin
  class PublicLogin
    UserAgent =  "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5"
    BaseUrl = "https://mp.weixin.qq.com/cgi-bin/login?lang=zh_CN"


    def  self.login(username = 'wangtuo314@163.com' , password = 'wangtuo19910314', code = nil)
      res, cookies, redirect_url, token = login_with_account(username, password, code)
      return res if res[0] == 'error'
      if token
        visitor_cookies = get_vistor_cookies(redirect_url, cookies, token)
        PublicWechatLogin.generate_account_login(username, password, visitor_cookies, token)
        return ['login_success']
      end
      res, ticket, operation_seq = get_ticket(cookies, redirect_url)
      return res if res[0] == 'error'
      appid = get_appid(cookies,redirect_url)
      uuid = get_uuid(cookies, redirect_url, appid, ticket)
      $cookies = cookies
      $redirect_url = redirect_url
      $ticket = ticket
      $operation_seq = operation_seq
      $uuid = uuid
      wechat_login = PublicWechatLogin.generate_qrcode_login(username, password, cookies, ticket, appid, uuid, operation_seq)
      qrcode_url = get_qrcode_url(ticket, uuid, operation_seq)
      return ['qrcode_success', wechat_login.id, qrcode_url]
    end


    def self.login_with_account(username, password, code = nil)
      params = {:username => username, :pwd =>  Digest::MD5.hexdigest(password)}
      params.merge({:imgcode => code})    if code.nil?
      request = Typhoeus.post(BaseUrl, followlocation: true, verbose: true,
                               :headers => {:user_agent => UserAgent,
                                            :referer => "https://mp.weixin.qq.com/",
                                            "Upgrade-Insecure-Requests" => 1
                               },
                               :params =>  params
                 )
      response = JSON.parse request.response_body   rescue {}
      cookies = ""
      if response["base_resp"] || response["base_resp"]["ret"] == 0
        request.response_headers.split("\n").each do |res_head|
          res = res_head.split(":")
          cookies << "#{res[1].split(";")[0]};"   if res[0].eql? "Set-Cookie"
        end
        redirect_url = "https://mp.weixin.qq.com/" + response["redirect_url"]
        if redirect_url.include?("token=")
          token = redirect_url.split("token=").last
          return ['losuccess', cookies , redirect_url, token]
        else
          return ['account_success', cookies , redirect_url]
        end
      elsif response["base_resp"].present? || response["base_resp"]["ret"] == '200027'
        return [['error', 'verify_code']]
      else
        return [['error', 'account_wrong']]
      end
    end

    def verify_code_url(username)
      "https://mp.weixin.qq.com/cgi-bin/verifycode?username=#{username}&r=#{Time.now.to_i}"
    end

    def self.get_ticket(cookies, redirect_url)
      assistant_req = Typhoeus.post("https://mp.weixin.qq.com/misc/safeassistant?1=1&token=&lang=zh_CN",
                                    :headers => {
                                       :user_agent => UserAgent,
                                       'X-Requested-With' => 'XMLHttpRequest',
                                       :referer => redirect_url,
                                       :Cookie => cookies
                                     },
                                    :body => "action=get_ticket&auth=ticket"
                                    )
      response = JSON.parse assistant_req.response_body  rescue {}
      if response["base_resp"] && response["base_resp"]["ret"] == 0
         return ['ticket_success', response["ticket"], response["operation_seq"]]
      else
        return [['error', 'request_wrong']]
      end
    end

    def self.get_appid(cookies,redirect_url)
      url = "https://res.wx.qq.com/c/=/mpres/zh_CN/htmledition/js/safe/safe_check2a92e6.js,/mpres/zh_CN/htmledition/js/common/wx/Step218877.js,/mpres/zh_CN/htmledition/js/safe/Scan2d3016.js,/mpres/zh_CN/htmledition/js/user/validate_wx2d3016.js"
      req = Typhoeus.get(url,
                          :headers => {
                            :user_agent => UserAgent,
                            'X-Requested-With' => 'XMLHttpRequest',
                            :referer => redirect_url,
                            :Cookie => cookies
                          })
      response = req.response_body
      appid = response.match(/appid:\"(.*?)\",/)[1]
      appid
    end

    def self.get_uuid(cookies, redirect_url, appid, ticket)
      random = rand(100000)
      req = Typhoeus.post("https://mp.weixin.qq.com/safe/safeqrconnect?1=1&token=&lang=zh_CN",
                           :headers => {
                             :user_agent => UserAgent,
                             'X-Requested-With' => 'XMLHttpRequest',
                             'Content-Type'=> "application/x-www-form-urlencoded",
                             :referer => redirect_url,
                             :Cookie => cookies
                           },
                           :body => "token=&lang=zh_CN&f=json&ajax=1&random=0.7635565#{random}&appid=#{appid}&scope=snsapi_contact&state=0&redirect_uri=https%3A%2F%2Fmp.weixin.qq.com&login_type=safe_center&type=json&ticket=#{ticket}"
      )
      response = JSON.parse req.response_body  rescue {}
      response["uuid"]
    end

    def self.get_qrcode_url(ticket, uuid, operation_seq)
      return "https://mp.weixin.qq.com/safe/safeqrcode?ticket=#{ticket}&uuid=#{uuid}&action=check&type=login&auth=ticket&msgid=#{operation_seq}"
    end

    def self.check_login_status_with_id(login_id)
      login =
    end


    def self.check_login_status(redirect_url, cookies, uuid, username, operation_seq )
      safeuuid_req = Typhoeus.post("https://mp.weixin.qq.com/safe/safeuuid?timespam=#{Time.now.to_i*1000}&token=&lang=zh_CN",
                                    :headers => {
                                       :user_agent => UserAgent,
                                       'X-Requested-With' => 'XMLHttpRequest',
                                       'Content-Type'=> "application/x-www-form-urlencoded",
                                       :referer => redirect_url,
                                       :Cookie => cookies
                                     },
                                    :body => "token=&lang=zh_CN&f=json&ajax=1&random=0.22103375891462052&uuid=#{uuid}&action=json&type=json")
      response = JSON.parse safeuuid_req.response_body  rescue {}
      if response['errcode'] == 405
        home_url, cookies,  token = get_token(redirect_url, cookies, uuid, username, operation_seq )
        vistor_cookies = get_vistor_cookies(home_url, cookies, token)
        return ['login_success',token, vistor_cookies]
      else
        return ['failure']
      end
    end

    def self.get_token(redirect_url, cookies, uuid, username, operation_seq )
      securewxverify_req = Typhoeus.post("https://mp.weixin.qq.com/cgi-bin/securewxverify",
                                         :headers => {
                                           :user_agent => UserAgent,
                                           'X-Requested-With' => 'XMLHttpRequest',
                                           'Content-Type'=> "application/x-www-form-urlencoded",
                                           :referer => redirect_url,
                                           :Cookie => cookies
                                         },
                                         :body => "token=&lang=zh_CN&f=json&ajax=1&random=0.8502100897504383&code=#{uuid}&account=#{username}&operation_seq=#{operation_seq}")
      cookies = ""
      securewxverify_req.response_headers.split("\n").each do |res_head|
        res = res_head.split(":")
        cookies << "#{res[1].split(";")[0]};"   if res[0].eql? "Set-Cookie"
      end
      response = JSON.parse securewxverify_req.response_body
      token = response["redirect_url"].split("token=").last
      home_url = "https://mp.weixin.qq.com#{response["redirect_url"]}"
      return [home_url, cookies, token]
    end

    def self.get_vistor_cookies(home_url, cookies, token)
      home_req = Typhoeus.get(home_url,
                              :headers => {
                                :user_agent => UserAgent,
                                "Upgrade-Insecure-Requests" => 1,
                                :Cookie => cookies
                              })
      vistor_cookies = ""
      home_req.response_headers.split("\n").each do |res_head|
        res = res_head.split(":")
        vistor_cookies << "#{res[1].split(";")[0]};"   if res[0].eql? "Set-Cookie"
      end
      return  vistor_cookies
    end
  end
end


qrcode_url = Weixin::PublicLogin.get_qrcode
puts "----qrcode_url:#{qrcode_url}"
while true
  res = Weixin::PublicLogin.check_login_status($redirect_url, $cookies, $uuid, $username, $operation_seq)
  puts "=========res#{res}"
  sleep 1.5
end
