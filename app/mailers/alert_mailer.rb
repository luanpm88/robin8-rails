class AlertMailer < ApplicationMailer
  add_template_helper(ImageProxyHelper)
  layout nil
  
  def recent_stories(alert_id)
    @alert = Alert.find(alert_id)
    @stream = @alert.stream
    @user = @stream.user
    
    client = AylienPressrApi::Client.new
    
    last_seen_story = if @alert.last_email_sent_at && @stream.last_seen_story_at
      [@alert.last_email_sent_at, @stream.last_seen_story_at].max
    elsif @stream.last_seen_story_at
      @stream.last_seen_story_at
    else
      Time.now
    end.utc.iso8601
    
    topics = @stream.topics.map {|a| a["id"]}
    keywords = @stream.keywords.map {|a| a['id']}
    blog_ids = @stream.blogs.map {|a| a['id']}
    sort_column = @stream.sort_column
    published_at = @stream.published_at.blank? ? "[* TO *]" : @stream.published_at
    published_at = "[* TO *]" if sort_column == "published_at"
    
    response = client.uniq_stories! "published_at" => "[#{last_seen_story} TO *]",
      "per_page" => 11, "topics" => topics, "keywords" => keywords, 
      "blog_ids" => blog_ids, "sort_column" => sort_column
    
    @stories = response[:stories]
    
    @stories = summarize_stories(@stories)
    
    if @stories.count > 0
      mail(to: @alert.email, subject: "Robin8 streams alert - #{@stream.name}")
      @alert.update_column(:last_email_sent_at, Time.now.utc)
    end
  end
  
  private
  
  def summarize_stories(stories)
    stories_summary = {}
    text_api_client = AylienTextApi::Client.new
    threads = []
    
    stories.each do |story|
      threads << Thread.new do
        stories_summary[story[:id]] = text_api_client.summarize title: story[:title], 
          text: story[:description]
      end
    end
    
    threads.each(&:join)
    
    stories.map do |s|
      s[:summary] = stories_summary[s[:id]][:sentences]
      s
    end
  end
end
