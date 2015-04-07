class AmazonDeleteWorker
  include Sidekiq::Worker

  def perform(stored_image)
    if stored_image.include? "http://s3.amazonaws.com"
      access_key_id = Rails.application.secrets.amazon[:key_id]
      secret_access_key = Rails.application.secrets.amazon[:secret_access_key]
      env_bucket = Rails.application.secrets.amazon[:bucket]
      s3 = AWS::S3.new(access_key_id: access_key_id, secret_access_key: secret_access_key)
      bucket = s3.buckets[env_bucket]
      amazon_file_key = stored_image.sub 'http://s3.amazonaws.com', 's3:/'
      bucket.objects.delete(amazon_file_key)
    end
  end

end