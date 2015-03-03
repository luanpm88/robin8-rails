class AmazonStorageWorker
  include Sidekiq::Worker
  
  def perform(news_room_id, new_logo, old_logo)
    news_room = NewsRoom.find(news_room_id)
    puts "*"*50
    puts 'Storing to Amazon S3...'
    uuid = new_logo
    q = HTTParty.post("https://api.uploadcare.com/files/", body: {source: uuid, target: "robin8-main"}, headers: {"Authorization" => "Uploadcare.Simple eaef90e4420402169d1f:09b94a326a95086338d6"})
    amazon_url = q.parsed_response
    puts amazon_url.class
    if amazon_url.is_a? String
      amazon_url.sub! '{"type": "url", "result": "s3:/', 'http://s3.amazonaws.com'
      amazon_url.sub! '"}', ""
    elsif
      amazon_url = amazon_url["result"]
      amazon_url.sub! 's3:/', 'http://s3.amazonaws.com'
    end
    puts "final url: " + amazon_url
    news_room.update_attribute(:logo_url, amazon_url)
    if old_logo
      AmazonDeleteWorker.perform_async(old_logo)
    end

  end
end