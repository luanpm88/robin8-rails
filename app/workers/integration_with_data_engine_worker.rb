class IntegrationWithDataEngineWorker
  include Sidekiq::Worker
  sidekiq_options :retry => 3

  sidekiq_retries_exhausted do |msg|
    Rails.logger.warn "Failed #{msg['class']} with #{msg['args']}: #{msg['error_message']}"
  end

  sidekiq_retry_in do |count|
    60 * (count + 1)
  end

  # @param type [String] - The type of HTTP action and url.
  # @param info [Hash] - A hash with keys :provider, :uid.
  def perform type, info

    base_url = Rails.application.secrets.data_engine_api_url

    res = case type
          when 'insert_kol'
            HTTParty.post base_url + '', info 
          when 'update_kol'
            HTTParty.put base_url + '', info
          when 'insert_campaign'
            HTTParty.post base_url + '', info
          end

  end
end
