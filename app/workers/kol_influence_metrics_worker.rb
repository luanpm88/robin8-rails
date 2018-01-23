class KolInfluenceMetricsWorker
  include Sidekiq::Worker
  sidekiq_options  :queue => :kol_influence_metrics_worker

  # Please refer to Lingkai's API documentations here
  # https://robin8.atlassian.net/wiki/spaces/RDP/pages/182616065/Lingkai+s+influence+score+API

  # first array is list of weibo user IDs, second array is list of wechat user IDs
  def perform weibo_user_ids, wechat_user_ids=[]
    body_hash = {
      callback_server: Rails.application.secrets[:domain],
      platform: 'weibo',
      social_id: weibo_user_ids
    }

    response = HTTParty.post(Rails.application.secrets[:influence_score_api],
                             body: body_hash.to_json,
                             headers: {'Content-Type' => 'application/json'}).parsed_response
    Rails.logger.info "---KolInfluenceMetricsWorker: #{response}"
  end
end
