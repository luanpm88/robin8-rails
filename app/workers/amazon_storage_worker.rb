class AmazonStorageWorker
  include Sidekiq::Worker

  def perform(object_type, object_id, new_url, old_url)
    if object_type == "news_room"
      object = NewsRoom.find(object_id)
      obj_attr = :logo_url
    elsif object_type == "user"
      obj_attr = :avatar_url
      object = User.find(object_id)
    end
    puts "*"*50
    puts 'Storing to Amazon S3...'
    uuid = new_url
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
    object.update_attribute(obj_attr, amazon_url)
    if old_url
      AmazonDeleteWorker.perform_in(20.seconds, old_url)
    end

  end
end