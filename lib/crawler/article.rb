require 'rubygems'
require 'nokogiri'
require 'mechanize'
# require '../crawler/doc'

module Crawler
  class Article < Doc
    def self.get_categories
      doc = get_doc("http://www.diaox2.com/category/100003.html")
      doc.css("#menu-list .menu-list-item").each do |category|
        title = category.css('.item-title')[0].text
        url = category.css('.item-title')[0].attr("href").gsub("..","http://www.diaox2.com" )
        puts title
        puts url
        category.css(".submenu-list .submenu-list-item").each do |sub_category|
          sub_name = sub_category.css("a")[0].text
          sub_url = sub_category.css("a")[0].attr("href").gsub("..","http://www.diaox2.com" )
          puts sub_name
          puts sub_url
          ArticleCategory.create!(name: title, url: url, sub_name: sub_name, sub_url: sub_url )
        end
      end
    end

    def self.get_aritcle_list
      ArticleCategory.all.each do |category|
        doc = get_doc(category.sub_url)
        doc.css(".img-container").each do |article_a|
          artcile_url = article_a.attr("href").gsub("..","http://www.diaox2.com")
          puts artcile_url
          get_article_content(artcile_url)
        end
      end
    end

    def self.get_article_content(article_url)
      doc = get_doc(article_url)
      title = doc.css(".article-area")[0].css(".article-title").text
      cover_url = doc.css(".article-area")[0].css(".article-banner-container li img")[0].attr("src")
      puts title
      puts cover_url
      contents = ""
      doc.css(".article-area .article>p").each do |p|
        if p.css("img").length > 0
          src = p.css("img")[0].attr("data-src")
          contents << "<img>#{src}"
        else
          text = p.text
          contents << "<text>#{text}"
        end
      end
      puts contents
      ArticleContent.create(title: title, cover_url: cover_url,)
    end
  end
end


Crawler::Article.get_aritcle_list
