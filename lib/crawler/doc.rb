module Crawler
  class Doc
    @@agent = nil
    @@weibo_cookies = nil
    def self.get_agent
      if @@agent.nil?
        @@agent = Mechanize.new
        @@agent.user_agent_alias = 'Mac Safari'
      end
      @@agent
    end

    def self.get_doc(home_page = 'http://www.meipai.com/user/21727149')
      Nokogiri::HTML(get_agent.get(home_page).body)
    end

    def self.trim(content)
      content.gsub("\n","").gsub("\r","").gsub(" ","")
    end

    def self.cover_num(num)
      if num.include?("万")
        thumb_num = num.split("万").first
        num = thumb_num.to_i * 10000
        num
      end
      num
    end

  end
end
