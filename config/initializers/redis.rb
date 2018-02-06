Redis::Objects.redis = Redis.new(url:      Rails.application.secrets[:redis][:url],
                                 password: Rails.application.secrets[:redis][:password])

$redis = Redis.new(url:      Rails.application.secrets[:redis][:url],
                   password: Rails.application.secrets[:redis][:password])
