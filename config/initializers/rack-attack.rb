class Rack::Attack
  
  # Blacklisting from Rails.cache
  Rack::Attack.blacklist('block <ip>') do |req|
    # if 'block #{req.ip}'exists in cache store, will block the request
    Rails.cache.fetch("block #{req.ip}").present?
  end

  Rack::Attack.throttle('req/ip', limit: 1000, period: 1.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end
end
