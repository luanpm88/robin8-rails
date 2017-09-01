class KolInfluenceMetricsWorker
  include Sidekiq::Worker

  # first array is list of weibo user IDs, second array is list of wechat user IDs
  def perform weibo_user_ids, wechat_user_ids=[]

    # use request_params when wechat is ready
    # provider_data = []
    # if weibo_user_ids.any?
    #   provider_data << {
    #     provider: 'weibo',
    #     social_id: weibo_user_ids
    #   }
    # end
    # if wechat_user_ids.any?
    #   provider_data << {
    #     provider: 'wechat',
    #     social_id: wechat_user_ids
    #   }
    # end
    # request_params = { uids: provider_data}

    server = Rails.env.production? ? 'http://robin8.net' : 'http://qa.robin8.net'
    body_hash = {
      callback_server: server,
      platform: 'weibo',
      social_id: weibo_user_ids
    }

    response = HTTParty.post(Rails.application.secrets[:influence_score_api],
                             body: body_hash.to_json,
                             headers: {'Content-Type' => 'application/json'}).parsed_response
    Rails.logger.info "---KolInfluenceMetricsWorker: #{response}"
  end
end
