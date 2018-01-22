namespace :influence_score do
  task refresh: :environment do
    # Please refer to Lingkai's API documentations here
    # https://robin8.atlassian.net/wiki/spaces/RDP/pages/182616065/Lingkai+s+influence+score+API

    kols = InfluenceMetric.where('influence_metrics.updated_at < ?', DateTime.now - 1.day).pluck(:kol_id)
    uids_to_refresh = Identity.where(kol_id: kols).where(provider: 'weibo').pluck(:uid)

    body_hash = {
      callback_server: Rails.application.secrets[:domain],
      platform: 'weibo',
      social_id: uids_to_refresh
    }

    Rails.logger.info "---influence_score:refresh -- body_hash: #{body_hash}"

    response = HTTParty.post(Rails.application.secrets[:influence_score_api],
                             body: body_hash.to_json,
                             headers: {'Content-Type' => 'application/json'}).parsed_response

    Rails.logger.info "---influence_score:refresh -- response: #{response}"
  end
end
