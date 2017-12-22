require 'slack-notifier'

class Rack::Attack

  # Blacklisting from Rails.cache
  Rack::Attack.blacklist('block <ip>') do |req|
    # if 'block #{req.ip}'exists in cache store, will block the request
    Rails.cache.fetch("block #{req.ip}").present?
  end

=begin
  Rack::Attack.throttle('req/cookies', limit: 1000, period: 2.minutes) do |req|
    req.cookies['_robin8_visitor']
  end

  Rack::Attack.throttle('req/ip', limit: 1000, period: 2.minutes) do |req|
    req.ip unless Rack::Attack.throttle_whitelisted_path?(req)
  end

  Rack::Attack.throttle('my_campaigns_attack', limit: 30, period: 1.minutes) do |req|
    req.env['HTTP_AUTHORIZATION']
  end
=end

  self.blacklisted_response = lambda do |env|
    [ 503, {}, 'The server is currently unavailable (because it is overloaded or down for maintenance).' ]
  end

  def self.throttle_whitelisted_path?(req)
    (req.path.start_with?('/assets') || req.path.match(/v1_[\d]\/public_login\/check_status\z/)) ? true : false
  end

  ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, req|
    return if req.env['rack.attach.match_type'] == :blacklist

    rule = req.env['rack.attack.matched'] # req/ip
    type = req.env['rack.attack.match_type'] # :throttle
    discriminator = req.env['rack.attack.match_discriminator']

    data = req.env['rack.attack.match_data']
    period = data[:period]
    count = data[:count]

    # msg = "\n[env: #{Rails.env}][#{type} by #{rule}]: IP/Cookies `#{discriminator}` request count `#{count}` in `#{period}` seconds.\n ---- EOF ----"

    # slack_webhook_url = 'https://hooks.slack.com/services/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'
    # notifier = Slack::Notifier.new slack_webhook_url
    # notifier.ping msg
  end
end
