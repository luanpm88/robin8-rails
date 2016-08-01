module Crawler
  class Miaopai < Doc
    def self.get_content(home_page)
      doc = get_doc(home_page)
      return {} if doc.blank?
      info = {}
      info[:uid] = home_page.split("/").last
      info[:brief] = trim(doc.css('.nav_div3 h3')[1].text) rescue nil
      info[:avatar_url] = doc.css('.nav_div1 .peo')[0].attr("src") rescue nil
      info[:username] = trim(doc.css('.nav_div1 a').text) rescue nil
      info[:statuses_count] = trim(doc.css('.nav_bottom .n_b_con ul li')[0].css("a")[0].text).to_i rescue nil
      info[:reposts_count] = trim(doc.css('.nav_bottom .n_b_con ul li')[1].css("a")[0].text).to_i rescue nil
      info[:like_count] = trim(doc.css('.nav_bottom .n_b_con ul li')[2].css("a")[0].text).to_i rescue nil
      info[:friends_count] =trim(doc.css('.nav_div2 .box1 ol li')[0].css("a").text).to_i rescue nil
      info[:followers_count] = trim(doc.css('.nav_div2 .box1 ol li')[2].css("a").text).to_i rescue nil
      info[:city] = doc.css('.nav_div3 h3')[0].text rescue nil

      others = {}
      others[:is_vip] = (doc.css('.box1 .s_v').size > 0 rescue false)
      info[:others] = others

      info
    end

    def self.create_kol_info(social_account)
      doc = get_doc(social_account.homepage)
      contents = []
      doc.css('.D_main .D_video').each_with_index do |item, index|
        binding.pry
        return if index >= 3
        contents << item.css(".introduction p")[0].text.strip
        like_count_text =  item.css(".list li")[0].text
        if  like_count_text.include?("万")
          like_count = like_count_text.gsub(",","").match(/([\d\.]+)/)[1].to_f * 10000      rescue nil
        else
          like_count =like_count_text.gsub(",","").match(/([\d\.]+)/)[1].to_i            rescue nil
        end
        comment_count_text = item.css(".list li")[2].text
        if  comment_count_text.include?("万")
          comment_count = comment_count_text.gsub(",","").match(/([\d\.]+)/)[1].to_f * 10000      rescue nil
        else
          comment_count = comment_count_text.gsub(",","").match(/([\d\.]+)/)[1].to_i     rescue nil
        end
        read_count_text =  item.css(".D_head_name h2").children.last.text.strip.gsub(",","")
        if  read_count_text.include?("万")
          read_count = read_count_text.match(/([\d\.]+)/)[1].to_f * 10000     rescue nil
        else
          read_count = iread_count_text.match(/([\d\.]+)/)[1].to_i            rescue nil
        end
        KolShow.create(kol_id: social_account.kol_id, provider: 'miaopai', cover_url: (item.css("#video")[0].attr("pi") rescue nil),
                       like_count: like_count, read_count: read_count,
                       comment_count: comment_count,
                       publish_time:  ("2016-" + item.css(".D_head_name b")[0].text),
                       link: (item.css("#video")[0].attr("va") rescue nil),
                       desc: item.css(".introduction p")[0].text.strip)
      end
      # 更新头像 和关键字
      keywords = NlpService.get_analyze_content(contents)["wordcloud"].collect{|t| t['text']}
      keywords.each do |keyword|
        KolKeyword.create!(kol_id: social_account.kol_id, social_account_id: social_account.id, :keyword => keyword)
      end
    end
  end
end
