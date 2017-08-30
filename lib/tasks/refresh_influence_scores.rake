namespace :influence_score do
  task refresh: :environment do
    kols = InfluenceMetric.where('influence_metrics.updated_at < ?', DateTime.now - 1.day).pluck(:kol_id)
    uids_to_refresh = Identity.where(kol_id: kols).where(provider: 'weibo').pluck(:uid)

    # uids_to_refresh = InfluenceMetric.where('influence_metrics.updated_at < ?', DateTime.now - 1.day)
    #                      .joins(:kol)
    #                      .merge(Kol.joins(:identities)
    #                               .where('identities.provider="weibo"'))
    #                      .pluck('identities.uid')

    server = Rails.env.production? ? 'http://robin8.net' : 'http://qa.robin8.net'
    body_hash = {
      callback_server: server,
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
