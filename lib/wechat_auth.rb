# 微信普通授权的实现
# 普通授权用来调用微信提供的各种API．区别于网页授权

class WechatAuth
  class << self
    ACCESS_TOKEN_URL = "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=%s&secret=%s"
    ACCESS_TOKEN_KEY = "wechat_global_access_token"

    JSAPI_TICKET_URL = "https://api.weixin.qq.com/cgi-bin/ticket/getticket?access_token=%s&type=jsapi"
    JSAPI_TICKET_KEY = "wechat_global_jsapi_ticket"

    def access_token
      request_access_token unless $redis.exists(ACCESS_TOKEN_KEY)
      $redis.get(ACCESS_TOKEN_KEY)
    end

    def request_access_token
      values = Rails.application.secrets[:wechat].values_at(:app_id, :app_secret)
      request(ACCESS_TOKEN_URL % values) do |data|
        unless data["access_token"].blank?
          $redis.setex(ACCESS_TOKEN_KEY, 7200.seconds, data["access_token"])
        end
      end
    end

    def jsapi_ticket
      request_jsapi_ticket unless $redis.exists(JSAPI_TICKET_KEY)
      $redis.get(JSAPI_TICKET_KEY)
    end

    def request_jsapi_ticket
      request(JSAPI_TICKET_URL % access_token) do |data|
        unless data["ticket"].blank?
          $redis.setex(JSAPI_TICKET_KEY, 7200.seconds, data["ticket"])
        end
      end
    end

    def signature(nonce, ts, url)
      s = {
        noncestr: nonce,
        jsapi_ticket: self.jsapi_ticket,
        timestamp: ts,
        url: url
      }
      .sort
      .map{ |k,v| "#{k}=#{v}" }
      .join("&")

      Digest::SHA1.hexdigest(s)
    end

  private
    def request(url)
      begin
        res = RestClient::Request.execute({
          :method => :get,
          :url => url,
          :timeout => 5,
          :open_timeout => 5
        })

        data = JSON.parse(res.body)
        yield data if block_given?
      rescue
      end
    end
  end
end