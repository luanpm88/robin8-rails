module Crawler
  class Meipai < Doc
    def self.get_content(home_page)
      doc = get_doc(home_page)
      return {} if doc.blank?
      info = {}
      info[:uid] = home_page.split("/").last
      info[:brief] = trim(doc.css('.user-descript.break').text) rescue nil
      info[:username] = trim(doc.css('.user-name a').text) rescue nil
      info[:avatar_url] = trim(doc.css('.avatar.user-avatar')[0].attr("src")).split("!")[0] rescue nil
      info[:statuses_count] = cover_num(trim(doc.css('.user-num .user-num-item')[0].text.split("\n")[1])) rescue nil
      info[:reposts_count] = cover_num(trim(doc.css('.user-num .user-num-item')[1].text.split("\n")[1])) rescue nil
      info[:friends_count] = cover_num(trim(doc.css('.user-num .user-num-item')[2].text.split("\n")[1])) rescue nil
      info[:followers_count] = cover_num(trim(doc.css('.user-num .user-num-item')[3].text.split("\n")[1])) rescue nil
      if (doc.css('.user-name i')[0].attr("class").include?('icon-female')     rescue false)
        info[:gender] = '2'
      elsif (doc.css('.user-name i')[0].attr("class").include?('icon-male')    rescue false)
        info[:gender] = '1'
      else
        info[:gender] = '0'
      end
      others = {}
      others[:is_vip] = (doc.css('.pa.user-vip').size > 0 rescue false)
      info[:others] = others
      info
    end

    def self.create_kol_info(social_account)
      doc = get_doc(social_account.homepage)
      contents = []
      doc.css('#mediasList li').each_with_index do |li, index|
        return if index >= 3
        contents << li.css(".feed-description").text.strip
        KolShow.create(kol_id: social_account.kol_id, provider: 'meipai', cover_url: (li.css(".feed-v-wrap img")[0].attr("src") rescue nil),
                       like_count: (li.css(".detail-count .feed-like span").text rescue nil),
                       comment_count: (li.css(".detail-count .feed-comment span").text rescue nil),
                       publish_time:  ("2016-" + li.css(".feed-user .feed-time").text.gsub("\t","").gsub("\n","").lstrip rescue nil),
                       link: ("http://www.meipai.com" + li.css(".feed-description")[0].attr("href") rescue nil),
                       desc: li.css(".feed-description").text.strip)
      end
      # 更新头像 和关键字
      keywords = NlpService.get_analyze_content(contents)["wordcloud"].collect{|t| t['text']}
      keywords.each do |keyword|
        KolKeyword.create!(kol_id: social_account.kol_id, social_account_id: social_account.id, :keyword => keyword)
      end
    end
  end
end
