class AmazonStorageRelease
  include Sidekiq::Worker

  def perform(release_id)
    @release = Release.find(release_id)
    urls = @release.text.scan(/(?:https?:\/\/)?(?:www\.)?ucarecdn.com\/.*?\//)
    if urls.count > 0
      new_text = @release.text

      urls.each do |url|
        auth = "Uploadcare.Simple " + Rails.application.secrets.uploadcare
        env_bucket = Rails.application.secrets.amazon[:bucket]
        q = HTTParty.post("https://api.uploadcare.com/files/", body: {source: url, target: env_bucket}, headers: {"Authorization" => auth})
        amazon_url = q.parsed_response
        if amazon_url.is_a? String
          amazon_url.sub! '{"type": "url", "result": "s3:/', 'http://s3.amazonaws.com'
          amazon_url.sub! '"}', ""
        elsif
          amazon_url = amazon_url["result"]
          amazon_url.sub! 's3:/', 'http://s3.amazonaws.com'
        end
        new_text.gsub!(url, amazon_url)
      end
      @release.update_columns(text: new_text)
    end
  end

end
