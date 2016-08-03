module Crawler
  class Weibo
    #http://weibo.com/u/2270023994
    UserAgent =  "Mozilla/5.0 (Windows; U; Windows NT 5.1; zh-CN; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5"

    def self.get_content(home_page)
      request = Typhoeus.get(home_page, followlocation: true, verbose: true,
                              :headers => {:user_agent => UserAgent,
                                           :Referer => "http://weibo.com"
                              },
      )
      body = request.response_body
      doc = Nokogiri::HTML(body).css("script").to_s.match(/.*render_data\s=\s(.*?);<\/script>/)[1]      rescue nil
      return {} if doc.blank?
      unescape_doc =  CGI.unescapeHTML(doc.to_s)
      content = eval(unescape_doc.to_s.gsub("null", '""'))
      info = {}
      info[:uid] = content[:stage][:page][1][:id]
      return {} if  info[:uid].blank?
      info[:brief] = content[:stage][:page][1][:description]
      info[:username] = content[:stage][:page][1][:name]
      info[:statuses_count] = content[:stage][:page][1][:mblogNum]
      info[:friends_count] = content[:stage][:page][1][:attNum]
      info[:followers_count] = content[:stage][:page][1][:fansNum]
      info[:province] = content[:stage][:page][1][:nativePlace]
      info[:avatar_url] = content[:stage][:page][1][:avatar_hd]
      if content[:stage][:page][1][:ta] == '她'
        info[:gender] = '2'
      elsif content[:stage][:page][1][:ta] == '他'
        info[:gender] = '1'
      else
        info[:gender] = '0'
      end
      info[:verified] = content[:stage][:page][1][:verified]
      others = {}
      others[:verified_type] = content[:stage][:page][1][:verified_type]
      others[:verified_reason] = content[:stage][:page][1][:verified_reason]
      others[:itemid] = content[:stage][:page].last[:card_group].last[:itemid]
      info[:others] = others
      info
    end

    def self.get_posts(social_account ,itemid = '1005052270023994_-_WEIBO_INDEX_PROFILE_WEIBO_GROUP_OBJ',homepage = 'http://m.weibo.cn/u/2270023994')
      url = "http://m.weibo.cn/page/card?itemid=#{itemid}"
      request = Typhoeus.get(url, followlocation: true, verbose: true,
                             :headers => {:user_agent => UserAgent,
                                          :Referer => homepage
                             },
      )
      body = request.response_body
      content = JSON.parse(body)["data"]
      doc = Nokogiri::HTML(content).css("section article").each_with_index do | article, index|
        return if index >= 3
        KolShow
      end
      puts doc
    end

    def self.create_kol_info(social_account)
      puts "------create_kol_info------"
      return if social_account.others[:itemid].blank?
      homepage = social_account.get_weibo_homepage
      url = "http://m.weibo.cn/page/card?itemid=#{social_account.others[:itemid]}"
      request = Typhoeus.get(url, followlocation: true, verbose: true,
                             :headers => {:user_agent => UserAgent,
                                          :Referer => homepage
                             }
      )
      body = request.response_body
      content = JSON.parse(body)["data"]
      desc_contents = []
      Nokogiri::HTML(content).css("section article.wrapper-wb").each_with_index do | article, index|
        return if index >= 3
        KolShow.create(:kol_id => social_account.kol_id, :provider => 'weibo',
                       :desc => article.css(".content-wb").text,
                       :link => "http://m.weibo.cn/#{social_account.uid}/#{article.attr('data-mid')}",
                       :cover_url =>  (article.css(".img-wb a")[0].attr("href") rescue nil),
                       :publish_time => article.css("header time").text,
                       :repost_count => article.css("footer a")[0].css("span").text,
                       :comment_count => article.css("footer a")[1].css("span").text,
                       :like_count => article.css("footer a")[2].css("span").text)
        desc_contents <<  article.css(".content-wb").text
      end
      puts "=====keywords===#{desc_contents.inspect}"
      return if desc_contents.size == 0
      keywords = NlpService.get_analyze_content(desc_contents)["wordcloud"].collect{|t| t['text']}
      keywords.each do |keyword|
        KolKeyword.create!(kol_id: social_account.kol_id, social_account_id: social_account.id, :keyword => keyword)
      end
    end

    # {
    #   'stage': {
    #   'page': [{
    #              "mod_type": "mod\/topbar",
    #   "title": {"txt": "\u4e2a\u4eba\u4e3b\u9875", "txt_sub": false},
    #   "btn": {"left": "back", "right": {"icon": "more", "type": "more"}},
    #   "fixed": 1,
    #   "transparent": 1,
    #   "reg": {
    #   "left": {
    #   "txt": "\u6ce8\u518c",
    #   "type": "reg",
    #   "url": "http:\/\/m.weibo.cn\/reg\/index?containerid=100505&extparam=u2128470930&v_p=5&featurecode=20000181&ext=&fid=1005052128470930&uicode=10000011"
    # },
    #   "right": {
    #   "txt": "\u767b\u5f55",
    #   "type": "login",
    #   "url": "https:\/\/passport.weibo.cn\/signin\/welcome?entry=mweibo&r=http%3A%2F%2Fm.weibo.cn%2Fu%2F2128470930&containerid=100505&extparam=u2128470930"
    # }
    # }
    # }, {
    #   "h5icon": {"main": "http:\/\/u1.sinaimg.cn\/upload\/2013\/02\/22\/v_yellow_2x.png", "other": []},
    #   "background": "http:\/\/ww4.sinaimg.cn\/crop.0.0.640.640.640.750\/6ce2240djw1e8iktk4ohij20hs0hsmz6.jpg",
    #   "profile_image_url": "http:\/\/tva3.sinaimg.cn\/crop.0.0.1242.1242.50\/7edde392jw8etww1rlt3jj20yi0yin0l.jpg",
    #   "id": "2128470930",
    #   "description": "App\u7ed8\u56fe\u8fbe\u4eba \u7f8e\u62cd \u79d2\u62cd \u5c0f\u7ea2\u5507 \u5185\u6db5\u6bb5\u5b50 VS Media\u5b98\u65b9\u5408\u4f5c\u4f19\u4f34",
    #   "verified": "1",
    #   "verified_type": "0",
    #   "attNum": "453",
    #   "nativePlace": "\u5e7f\u4e1c",
    #   "mblogNum": "364",
    #   "fansNum": "2375",
    #   "following": "",
    #   "follow_me": "",
    #   "favourites_count": "232",
    #   "verified_reason": "\u5c0f\u7ea2\u5507app\u77e5\u540d\u7ed8\u56fe\u8fbe\u4eba",
    #   "name": "\u7f57\u8fdc\u9886",
    #   "avatar_hd": "http:\/\/tva3.sinaimg.cn\/crop.0.0.1242.1242.1024\/7edde392jw8etww1rlt3jj20yi0yin0l.jpg",
    #   "ptype": "0",
    #   "created_at": "Mon May 02 21:40:44 +0800 2011",
    #   "mbtype": "0",
    #   "mbrank": "0",
    #   "genderIcon": "http:\/\/u1.sinaimg.cn\/upload\/h5\/img\/female.png",
    #   "ta": "\u5979",
    #   "relation": "0",
    #   "desc_scheme": "\/users\/2128470930",
    #   "buttons": [{
    #                 "type": "link",
    #   "icon": "iconf_userinfo_message",
    #   "name": "\u79c1\u4fe1",
    #   "scheme": "\/msg\/chat?uid=2128470930"
    # }, {"type": "relation", "sub_type": 0, "uid": "2128470930"}],
    #   "mod_type": "mod\/cover"
    # }, {
    #   "mod_type": "mod\/pagelist",
    #   "previous_cursor": "",
    #   "next_cursor": "",
    #   "card_group": [{
    #                    "card_type": 2,
    #   "card_type_name": "\u5e94\u7528\u5217\u8868",
    #   "itemid": "1005052128470930_-_WEIBO_INDEX_PROFILE_APPS",
    #   "is_asyn": 1,
    #   "apps": [],
    #   "openurl": "",
    #   "async_api": "\/page\/card?itemid=1005052128470930_-_WEIBO_INDEX_PROFILE_APPS"
    # }, {
    #   "card_type": 11,
    #   "card_type_name": "\u5fae\u535a",
    #   "itemid": "1005052128470930_-_WEIBO_INDEX_PROFILE_WEIBO_GROUP_OBJ",
    #   "is_asyn": 1,
    #   "card_group": [],
    #   "openurl": "",
    #   "async_api": "\/page\/card?itemid=1005052128470930_-_WEIBO_INDEX_PROFILE_WEIBO_GROUP_OBJ"
    # }]
    # }]
    # },
    #   'common': {
    #   "cacheHit": 0,
    #   "isLogin": false,
    # "loginUrl": "https:\/\/passport.weibo.cn\/signin\/welcome?entry=mweibo&r=http%3A%2F%2Fm.weibo.cn%2Fu%2F2128470930&containerid=100505&extparam=u2128470930",
    #   "wx_callback": "https:\/\/passport.weibo.com\/othersitebind\/authorize?entry=h53rdlanding&site=qq&callback=http%3A%2F%2Fm.weibo.cn%2Fu%2F2128470930",
    #   "wx_authorize": "https:\/\/passport.weibo.com\/othersitebind\/authorize?site=weixin&entry=sinawap&type=normal&callback=http%3A%2F%2Fm.weibo.cn%2Fu%2F2128470930",
    #   "passport_login_url": "https:\/\/passport.weibo.cn\/signin\/login?entry=mweibo&r=http%3A%2F%2Fm.weibo.cn%2Fu%2F2128470930",
    #   "deviceType": "UNKNOWN",
    #   "browserType": "UNKNOWN",
    #   "online": true,
    # "wm": null,
    # "st": "453925",
    #   "isInClient": 0,
    #   "isWechat": 0,
    #   "hideHeaderBanner": 0,
    #   "request_key": "c0a60832a46d0a0976f8c4f56c3fde8a",
    #   "uid": false,
    # "containerid": "1005052128470930",
    #   "hidemenu": null,
    # "hideFooterPage": true,
    # "partner": 0,
    #   "callClient": 0,
    #   "hideNotice": 0,
    #   "hideLoginBanner": 0,
    #   "showPopLogin": 0,
    #   "showLoginButton": 1,
    #   "seeLevel": 2,
    #   "pageType": "userInfo",
    #   "scheme": "sinaweibo:\/\/userinfo?uid=2128470930&luicode=10000011&lfid=",
    #   "title": "\u4e2a\u4eba\u4e3b\u9875",
    #   "params": {
    #   "containerid": "100505",
    #   "extparam": "u2128470930",
    #   "v_p": 5,
    #   "featurecode": 20000181,
    #   "ext": "",
    #   "fid": "1005052128470930",
    #   "uicode": 10000011
    # },
    #   "ctrl": "pages\/index",
    #   "stage": "page"
    # }
    # }
  end

end

