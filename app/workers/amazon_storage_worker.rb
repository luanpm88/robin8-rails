class AmazonStorageWorker
  include Sidekiq::Worker

  def perform(object_type, object_id, new_url, old_url, attribute)
    object = object_type.classify.constantize.find(object_id)
    uuid = new_url
    auth = "Uploadcare.Simple " + Rails.application.secrets.uploadcare
    q = HTTParty.post("https://api.uploadcare.com/files/", body: {source: uuid, target: "robin8-main"}, headers: {"Authorization" => auth})
    amazon_url = q.parsed_response
    if amazon_url.is_a? String
      amazon_url.sub! '{"type": "url", "result": "s3:/', 'http://s3.amazonaws.com'
      amazon_url.sub! '"}', ""
    elsif
      amazon_url = amazon_url["result"]
      amazon_url.sub! 's3:/', 'http://s3.amazonaws.com'
    end
    object.update_attribute(attribute, amazon_url)
    if old_url
      AmazonDeleteWorker.perform_in(20.seconds, old_url)
    end
  end

end