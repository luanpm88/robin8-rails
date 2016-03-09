class IntegrationWithDataEngineWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  def perform spider_type, identity_id
    IntegrationWithDataEngineWorker.spider_weibo_data spider_type, identity_id
  end

  def self.spider_weibo_data spider_type, identity_id
    identity = Identity.where(:id => identity_id).first
    return unless identity

    response = RestClient.get Rails.application.secrets.weibo[:user_timeline_url], {:params => {access_token: identity.token}}
    # request = Typhoeus::Request.new(Rails.application.secrets.weibo[:user_timeline_url], params: {access_token: identity.token})
    # request.run
    # response = request.response
    data = JSON.parse response.body
    if data["error_code"].present?
      Rails.logger.error "identity_id: #{identity_id} 抓取失败, #{data}"
      return
    end
    new_data = []

    data["statuses"].each do |item|
      id = item["id"]
      cache_key = "user_feed_ids:#{id}"
      unless Rails.cache.fetch(cache_key)
        new_data << item
        Rails.cache.write(cache_key, 1, :expires_in => 1.days)
      end
    end

    if new_data.empty?
      IntegrationWithDataEngineWorker.delay_for(1.5.hour).perform_async(spider_type, identity_id)
      return
    end

    response = RestClient.post Rails.application.secrets.weibo[:integration_data_api], new_data.to_json
    body = JSON.parse response

    if body["return_code"] == 0
      IntegrationWithDataEngineWorker.delay_for(1.5.hour).perform_async(spider_type, identity_id)
    end
  end
end
