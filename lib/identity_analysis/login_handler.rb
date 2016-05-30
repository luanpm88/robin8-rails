# Weixin::LoginHandler.login_with_qrcode
require 'rubygems'
require 'typhoeus'
require 'nokogiri'

module Weixin
  class LoginHandler
    UserAgent =  "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5"
    def self.login_with_qrcode(username = 'huxiaolong100@126.com' , password = '123qweQWE')
      ####### 二维码的 登录过程######
      ##############  第一步登录  begin   ###########
      response = Typhoeus.post(base_url, followlocation: true, cookiefile: "./cookie", cookiejar: "./cookie", verbose: true,
                               :headers => {
                                 :user_agent => UserAgent,
                                 :referer => "https://mp.weixin.qq.com/",
                                 "Upgrade-Insecure-Requests" => 1,
                               },
                               :params => {
                                 :username => username,
                                 :pwd =>  Digest::MD5.hexdigest(password)

                               }
      );

      puts "登录后: #{response.response_body}"

      ##############  第一步登录  end   ###########

      ##############  第二步登录  二维码   ###########
      headers = {}
      res_headers = response.response_headers.split("\n")
      res_headers.each do |res_head|
        res = res_head.split(":")
        if res[0].eql? "Set-Cookie"
          headers["Cookie"] = "#{headers["Cookie"]};#{res[1].split(";")[0]}"
        end
      end;nil


      url = "https://mp.weixin.qq.com/" + (JSON.parse response.response_body)["redirect_url"]
      # step_2_response = Typhoeus.get(url,:headers => {
      #                                     :user_agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5",
      #                                     "Upgrade-Insecure-Requests" => 1,
      #                                     :Cookie => headers["Cookie"],
      #                                     :referer => "https://mp.weixin.qq.com/"
      #                                   });nil
      #
      # body = Nokogiri::HTML(step_2_response.response_body)

      ############### 获取 ticket id begin ############
      ssistant_response = Typhoeus.post("https://mp.weixin.qq.com/misc/safeassistant?1=1&token=&lang=zh_CN",:headers => {
                                                                                                             :user_agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5",
                                                                                                             'X-Requested-With' => 'XMLHttpRequest',
                                                                                                             :referer => url,
                                                                                                             :Cookie => headers["Cookie"]
                                                                                                           }, :body => "action=get_ticket&auth=ticket");nil

      puts "获取ticket id: #{ssistant_response.response_body}"
      ############### 获取 ticket id end ############

      ############### 获取 获取uuid begin ############

      # https://res.wx.qq.com/c/=/mpres/zh_CN/htmledition/js/safe/safe_check2a92e6.js,/mpres/zh_CN/htmledition/js/common/wx/Step218877.js,/mpres/zh_CN/htmledition/js/safe/Scan2d3016.js,/mpres/zh_CN/htmledition/js/user/validate_wx2d3016.js
      # appid 通过上面的js 获取
      safeqrconnect_response = Typhoeus.post("https://mp.weixin.qq.com/safe/safeqrconnect?1=1&token=&lang=zh_CN",:headers => {
                                                                                                                  :user_agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5",
                                                                                                                  'X-Requested-With' => 'XMLHttpRequest',
                                                                                                                  'Content-Type'=> "application/x-www-form-urlencoded",
                                                                                                                  :referer => url,
                                                                                                                  :Cookie => headers["Cookie"]
                                                                                                                },
                                             :body => "token=&lang=zh_CN&f=json&ajax=1&random=0.7635565652589176&appid=wx3a432d2dbe2442ce&scope=snsapi_contact&state=0&redirect_uri=https%3A%2F%2Fmp.weixin.qq.com&login_type=safe_center&type=json&ticket=#{(JSON.parse ssistant_response.response_body)['ticket']}");nil

      puts "获取 appid #{safeqrconnect_response.response_body}"

      ############### 获取 获取uuid end ############

      ssistant_response_body = JSON.parse ssistant_response.response_body
      safeqrconnect_response_body = JSON.parse safeqrconnect_response.response_body

      ############### 获取 生成图片链接 begin ############
      img_url = "https://mp.weixin.qq.com/safe/safeqrcode?ticket=#{ssistant_response_body['ticket']}&uuid=#{safeqrconnect_response_body['uuid']}&action=check&type=login&auth=ticket&msgid=#{ssistant_response_body['operation_seq']}"

      # https://mp.weixin.qq.com/misc/safeassistant?1=1&token=&lang=zh_CN
      # https://mp.weixin.qq.com/safe/safeqrconnect?1=1&token=&lang=zh_CN
      puts "二维码图片地址: #{img_url}"
      ############### 获取 生成图片链接 end ############

      while true
        ######### 轮询检测 是否 登录成功 ######
        safeuuid_response = Typhoeus.post("https://mp.weixin.qq.com/safe/safeuuid?timespam=#{Time.now.to_i*1000}&token=&lang=zh_CN",:headers => {
                                                                                                                                     :user_agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5",
                                                                                                                                     'X-Requested-With' => 'XMLHttpRequest',
                                                                                                                                     'Content-Type'=> "application/x-www-form-urlencoded",
                                                                                                                                     :referer => url,
                                                                                                                                     :Cookie => headers["Cookie"]
                                                                                                                                   },
                                          :body => "token=&lang=zh_CN&f=json&ajax=1&random=0.22103375891462052&uuid=#{safeqrconnect_response_body['uuid']}&action=json&type=json");nil
        begin
          puts "获取 safeuuid_response: ", safeuuid_response.response_body
        rescue Exception => e
        end
        body = JSON.parse safeuuid_response.response_body
        if body["errcode"] == 405
          ######### 登录成功了 ##############

          safeassistant_response = Typhoeus.post("https://mp.weixin.qq.com/misc/safeassistant?1=1&token=&lang=zh_CN",:headers => {
                                                                                                                      :user_agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5",
                                                                                                                      'X-Requested-With' => 'XMLHttpRequest',
                                                                                                                      'Content-Type'=> "application/x-www-form-urlencoded",
                                                                                                                      :referer => url,
                                                                                                                      :Cookie => headers["Cookie"]
                                                                                                                    },
                                                 :body => "token=&lang=zh_CN&f=json&ajax=1&random=0.2747726457376827&action=get_uuid&uuid=#{safeqrconnect_response_body['uuid']}&auth=ticket");nil
          puts "获取 safeassistant#{safeassistant_response.response_body}"
          ######### 获取 verify, 设置cookie #####
          securewxverify_response = Typhoeus.post("https://mp.weixin.qq.com/cgi-bin/securewxverify",:headers => {
                                                                                                     :user_agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5",
                                                                                                     'X-Requested-With' => 'XMLHttpRequest',
                                                                                                     'Content-Type'=> "application/x-www-form-urlencoded",
                                                                                                     :referer => url,
                                                                                                     :Cookie => headers["Cookie"]
                                                                                                   },
                                                  :body => "token=&lang=zh_CN&f=json&ajax=1&random=0.8502100897504383&code=#{safeqrconnect_response_body['uuid']}&account=897569984%40qq.com&operation_seq=ssistant_response_body['operation_seq']");nil
          puts "获取 securewxverify_response： #{securewxverify_response.response_body}"
          headers = {}
          res_headers = securewxverify_response.response_headers.split("\n")
          res_headers.each do |res_head|
            res = res_head.split(":")
            if res[0].eql? "Set-Cookie"
              headers["Cookie"] = "#{headers["Cookie"]};#{res[1].split(";")[0]}"
            end
          end;nil

          ############### 获取token ############
          body = JSON.parse securewxverify_response.response_body
          url = "https://mp.weixin.qq.com#{body["redirect_url"]}"
          response = Typhoeus.get(url,
                                  :headers => {
                                    :user_agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5",
                                    "Upgrade-Insecure-Requests" => 1,
                                    :Cookie => headers["Cookie"]
                                  }
          )

          headers = {}
          res_headers = response.response_headers.split("\n")
          res_headers.each do |res_head|
            res = res_head.split(":")
            if res[0].eql? "Set-Cookie"
              headers["Cookie"] = "#{headers["Cookie"]};#{res[1].split(";")[0]}"
            end
          end;nil

          #################获取 用户的 列表 #############

          url = "https://mp.weixin.qq.com/cgi-bin/user_tag?action=get_user_list&groupid=-2&begin_openid=ospUnszeUljnj6Ar3m722eFpz5CU&begin_create_time=1462042979&limit=20&offset=0&backfoward=1&token=#{body["redirect_url"].split("token=").last}&lang=zh_CN&f=json&ajax=1&random=0.11402073825290082"
          response = Typhoeus.get(url,
                                  :headers => {
                                    :user_agent => "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5",
                                    "Upgrade-Insecure-Requests" => 1,
                                    :Cookie => headers["Cookie"]
                                  }
          )


          puts "抓取微信的用户数据：", response.response_body
          break
        end
        sleep 2
      end
    end


    def self.base_url
      # http://www.brownfort.com/2014/09/scrap-websites-ruby/
      "https://mp.weixin.qq.com/cgi-bin/login?lang=zh_CN"
    end
  end
end


Weixin::LoginHandler.login_with_qrcode
