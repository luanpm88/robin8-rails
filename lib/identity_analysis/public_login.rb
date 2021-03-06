require 'rubygems'
require 'typhoeus'

module IdentityAnalysis
  class PublicLogin
    UserAgent =  "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5"
    BaseUrl = "https://mp.weixin.qq.com/cgi-bin/login"

    def  self.login(kol_id, username = 'wangtuo314@163.com' , password = 'wan', imgcode = nil, cookies = nil)
      res, cookies, redirect_url, token = login_with_account(username, password, imgcode, cookies)
      return res if res[0] == 'error'
      if token
        wechat_login = PublicWechatLogin.generate_account_login(kol_id,username, password, cookies, token)
        return ['login_success', wechat_login.id]
      end
      res, ticket, operation_seq = get_ticket(cookies, redirect_url)
      return res if res[0] == 'error'
      appid = get_appid(cookies,redirect_url)
      uuid = get_uuid(cookies, redirect_url, appid, ticket)
      wechat_login = PublicWechatLogin.generate_qrcode_login(kol_id, username, password, cookies, ticket, appid, uuid, operation_seq, redirect_url)
      qrcode_url = get_qrcode_url(ticket, uuid, operation_seq)
      return ['qrcode_success', wechat_login.id, qrcode_url]
    end


    def self.login_with_account(username, password, imgcode = nil, cookie)
      params = {:username => username, :pwd =>  Digest::MD5.hexdigest(password), :f => "json"}
      params.merge!({:imgcode => imgcode})    if imgcode.present?
      request = Typhoeus.post(BaseUrl, followlocation: true, verbose: true,
                               :headers => {:user_agent => UserAgent,
                                            'X-Requested-With' => 'XMLHttpRequest',
                                            :Referer => "https://mp.weixin.qq.com/",
                                            :Cookie => cookie
                               },
                               :params =>  params
                 )
      response = JSON.parse(request.response_body)  || {}  rescue {}
      Rails.logger.info "=======login_with_account======="
      Rails.logger.info cookie
      Rails.logger.info  response.inspect
      cookies = ""
      if response["base_resp"].present? && response["base_resp"]["ret"] == 0
        cookies = append_cookies(cookies, request)
        redirect_url = "https://mp.weixin.qq.com/#{response['redirect_url']}"
        if redirect_url.include?("token=")
          token = redirect_url.split("token=").last
          return ['login_success', cookies , redirect_url, token]
        else
          return ['account_success', cookies , redirect_url]
        end
      elsif response["base_resp"].present? && (response["base_resp"]["ret"].to_s == '200027' || response["base_resp"]["ret"].to_s == '200008')
        return [['error', 'verify_code']]
      else
        return [['error', 'account_wrong']]
      end
    end

    def self.verify_code_url(username)
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
      response = JSON.parse(assistant_req.response_body) || {}   rescue {}
      if response["base_resp"] && response["base_resp"]["ret"] == 0
         return ['ticket_success', response["ticket"], response["operation_seq"]]
      else
        return [['error', 'request_wrong']]
      end
    end

    def self.get_appid_url(cookies, redirect_url)
      readtemplate_req = Typhoeus.get(redirect_url,
                                    :headers => {
                                      :user_agent => UserAgent,
                                      'X-Requested-With' => 'XMLHttpRequest',
                                      :Cookie => cookies,
                                      :referer => "https://mp.weixin.qq.com/",
                                    })
      body = readtemplate_req.response_body.to_s
      url = body.match(/onerror=\"wx_loaderror\(this\)\".*src=\"(.*safe_check.*validate.*js)\"/)[1] rescue nil
      url
    end

    def self.get_appid(cookies,redirect_url)
      url = get_appid_url(cookies,redirect_url)
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
      response = JSON.parse(req.response_body)  || {}  rescue {}
      response["uuid"]
    end

    def self.get_qrcode_url(ticket, uuid, operation_seq)
      return "https://mp.weixin.qq.com/safe/safeqrcode?ticket=#{ticket}&uuid=#{uuid}&action=check&type=login&auth=ticket&msgid=#{operation_seq}"
    end


    def self.check_login_status(login_id)
      login =  PublicWechatLogin.find login_id
      return if login.blank?
      cookies = login.visitor_cookies
      uuid = login.uuid
      username = login.username
      operation_seq = login.operation_seq
      redirect_url = login.redirect_url
      safeuuid_req = Typhoeus.post("https://mp.weixin.qq.com/safe/safeuuid?timespam=#{Time.now.to_i*1000}&token=&lang=zh_CN",
                                    :headers => {
                                       :user_agent => UserAgent,
                                       'X-Requested-With' => 'XMLHttpRequest',
                                       'Content-Type'=> "application/x-www-form-urlencoded",
                                       :referer => redirect_url,
                                       :Cookie => cookies
                                     },
                                    :body => "token=&lang=zh_CN&f=json&ajax=1&random=0.22103375891462052&uuid=#{uuid}&action=json&type=json")
      response = JSON.parse(safeuuid_req.response_body) || {}   rescue {}
      if response['errcode'] == 405
        token = secure_wx_verify(redirect_url, cookies, uuid, username, operation_seq )
        login.success_qrcode_login(cookies, token)
        return response['errcode']
      else
        return response['errcode']
      end
    end

    def self.secure_wx_verify(redirect_url, cookies, uuid, username, operation_seq )
      securewxverify_req = Typhoeus.post("https://mp.weixin.qq.com/cgi-bin/securewxverify",
                                         :headers => {
                                           :user_agent => UserAgent,
                                           'X-Requested-With' => 'XMLHttpRequest',
                                           'Content-Type'=> "application/x-www-form-urlencoded",
                                           :referer => redirect_url,
                                           :Cookie => cookies
                                         },
                                         :body => "token=&lang=zh_CN&f=json&ajax=1&random=0.8502100897504383&code=#{uuid}&account=#{username}&operation_seq=#{operation_seq}")
      append_cookies(cookies, securewxverify_req)
      response = JSON.parse securewxverify_req.response_body  || {}
      token = response["redirect_url"].split("token=").last
      return token
    end

    def self.visit_home
      public_login = PublicWechatLogin.last
      cookies = public_login.visitor_cookies
      token = public_login.token
      referer = public_login.redirect_url
      home_url = "https://mp.weixin.qq.com/cgi-bin/home?t=home/index&lang=zh_CN&token=#{token}"
      home_req = Typhoeus.get(home_url,
                              :headers => {
                                :user_agent => UserAgent,
                                "Upgrade-Insecure-Requests" => 1,
                                :Cookie => cookies,
                                :referer => referer || 'https://mp.weixin.qq.com/'
                              })
      puts home_req.response_body
    end

    def self.append_cookies(cookies, req)
      cookies ||= ""
      req.response_headers.split("\n").each do |res_head|
        res = res_head.split(":")
         if res[0].eql?("Set-Cookie")
           cookies_body =  res[1].split(";")[0]
           cookies << "#{cookies_body};"   if !cookies.include?(cookies_body)
         end
      end
      cookies
    end

  end
end
