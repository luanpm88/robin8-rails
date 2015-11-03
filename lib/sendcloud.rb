module Sendcloud

  class Client
    def initialize(api_key=Rails.application.secrets.sendcloud[:api_key],
                   api_user=Rails.application.secrets.sendcloud[:api_user],
                   api_url='http://sendcloud.sohu.com/webapi')

      @http_client = RestClient::Resource.new(api_url)
      @auth = { :api_user => api_user, :api_key => api_key }
    end

    def send_message data
      post_data = data.merge @auth
      res = @http_client['/mail.send.json'].post(post_data)
      res_body_obj = JSON.parse res.body

      unless res_body_obj['message'].eql?('success')
        raise res.body
      end

      true
    end

  end
end
