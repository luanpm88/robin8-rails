class TextAlertWorker
  include Sidekiq::Worker

  def perform(alert_id)
    alert = Alert.find(alert_id)
    stream = alert.stream
    
    client = AylienPressrApi::Client.new
    
    last_seen_story = (alert.last_text_sent_at || stream.last_seen_story_at).utc.iso8601
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
    count_message = (stories.count > 10) ? "more than 10" : stories.count
    message = "Hey there! There are #{count_message} new stories " +
              "in the '#{stream.name}' stream in Robin8. " + 
              "Please go to https://robin8.com to read the stories."
    
    if stories.count == 1
      message = "Hey there! There is a new story " +
              "in the '#{stream.name}' stream in Robin8. " + 
              "Please go to https://robin8.com to read the story."
    end
    
    if stories.count > 0
      twilio_client = Twilio::REST::Client.new
      twilio_client.messages.create(
        from: Rails.application.secrets.twilio[:from],
        to: alert.phone,
        body: message
      )
      alert.update_column(:last_text_sent_at, Time.now.utc)
    end
  end
end
