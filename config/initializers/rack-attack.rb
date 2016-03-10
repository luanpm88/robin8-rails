class Rack::Attack
  
  # Blacklisting from Rails.cache
  Rack::Attack.blacklist('block <ip>') do |req|
    # if 'block #{req.ip}'exists in cache store, will block the request
    Rails.cache.fetch("block #{req.ip}").present?
  end

  Rack::Attack.throttle('req/cookies', limit: 1000, period: 2.minutes) do |req|
    req.cookies['_robin8_visitor']
  end

  Rack::Attack.throttle('req/ip', limit: 1000, period: 2.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  self.blacklisted_response = lambda do |env|
    [ 503, {}, 'The server is currently unavailable (because it is overloaded or down for maintenance).' ]
  end
end
