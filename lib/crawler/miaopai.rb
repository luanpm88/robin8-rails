module Crawler
  class Miaopai < Doc
    def self.get_content(home_page)
      doc = get_doc(home_page)
      return {} if doc.blank?
      info = {}
      info[:brief] = trim(doc.css('.nav_div3 h3')[1].text) rescue nil
      info[:username] = trim(doc.css('.nav_div1 a').text) rescue nil
      info[:statuses_count] = trim(doc.css('.nav_bottom .n_b_con ul li')[0].css("a")[0].text).to_i rescue nil
      info[:reposts_count] = trim(doc.css('.nav_bottom .n_b_con ul li')[1].css("a")[0].text).to_i rescue nil
      info[:like_count] = trim(doc.css('.nav_bottom .n_b_con ul li')[2].css("a")[0].text).to_i rescue nil
      info[:friends_count] =trim(doc.css('.nav_div2 .box1 ol li')[0].css("a").text).to_i rescue nil
      info[:followers_count] = trim(doc.css('.nav_div2 .box1 ol li')[2].css("a").text).to_i rescue nil
      info[:location] = doc.css('.nav_div3 h3')[0].text rescue nil
      info
    end
  end
end
