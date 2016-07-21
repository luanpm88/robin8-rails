module Crawler
  class Meipai < Doc
    def self.get_content(home_page)
      doc = get_doc(home_page)
      return {} if doc.blank?
      info = {}
      info[:brief] = trim(doc.css('.user-descript.break').text) rescue nil
      info[:username] = trim(doc.css('.user-name a').text) rescue nil
      info[:statuses_count] = cover_num(trim(doc.css('.user-num .user-num-item')[0].text.split("\n")[1])) rescue nil
      info[:reposts_count] = cover_num(trim(doc.css('.user-num .user-num-item')[1].text.split("\n")[1])) rescue nil
      info[:friends_count] = cover_num(trim(doc.css('.user-num .user-num-item')[2].text.split("\n")[1])) rescue nil
      info[:followers_count] = cover_num(trim(doc.css('.user-num .user-num-item')[3].text.split("\n")[1])) rescue nil
      info
    end
  end
end
