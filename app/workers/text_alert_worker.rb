class TextAlertWorker
  include Sidekiq::Worker

  def perform(alert_id)
    alert = Alert.find(alert_id)
    stream = alert.stream
    
    client = AylienPressrApi::Client.new
    
    last_seen_story = stream.last_seen_story_at.utc.iso8601
    topics = stream.topics.map {|a| a["id"]}
    keywords = stream.keywords.map {|a| a['id']}
    blog_ids = stream.blogs.map {|a| a['id']}
    sort_column = stream.sort_column
    published_at = stream.published_at.blank? ? "[* TO *]" : stream.published_at
    published_at = "[* TO *]" if sort_column == "published_at"
    
    response = client.uniq_stories! "published_at" => "[#{last_seen_story} TO *]",
      "per_page" => 11, "topics" => topics, "keywords" => keywords, 
      "blog_ids" => blog_ids, "sort_column" => sort_column
      
    stories = response[:stories]
    
    if stories.count > 0
      twilio_client = Twilio::REST::Client.new
      twilio_client.messages.create(
        from: Rails.application.secrets.twilio[:from],
        to: alert.phone,
        body: "Hey there! You have new stories in Robin8 streams (#{stream.name})." + 
          "Please go to https://robin8.com to read the stories."
      )
      alert.update_column(:last_text_sent_at, Time.now.utc)
    end
  end
end
