xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", "xmlns:media" => 'http://search.yahoo.com/mrss/' do
  xml.channel do
    xml.title "Topics: #{topicsForRss}"
    xml.description "Blogs: #{blogsForRss}"
    xml.link stories_stream_url(stream_id)

    for story in stories["stories"]
      xml.item do
        xml.title story["blog_name"]
        xml.description story["title"]
        xml.pubDate Time.new(story["published_at"]).to_s(:rfc822)
        xml.link story['link']
        xml.guid "#{story['link']}-#{story['id']}"
        if story['images'].length
          xml.media :content, url: story['images'][0], height: 50, width:50, type:"image/jpeg"
        end
      end
    end
  end
end