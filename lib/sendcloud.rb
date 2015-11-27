module Sendcloud

  class Client
    def initialize(api_key=Rails.application.secrets.sendcloud[:api_key],
                   api_user=Rails.application.secrets.sendcloud[:api_user],
                   api_url='http://sendcloud.sohu.com/webapi')

      @http_client = RestClient::Resource.new(api_url)
      @auth = { :api_user => api_user, :api_key => api_key }
    end

    # send_template data example
    # {
    #   :api_user => '',
    #   :api_key => '',
    #   :from => '',
    #   :fromname => '',
    #   :substitution_vars => JSON.dump({"to" => ['address1@g.cn'], "sub" => {"%code%" => "code"}}),
    #   :template_invoke_name => '',
    #   :subject => ''
    # }

    # send data example (via common method)
    # {
    #   :api_user => '',
    #   :api_key => '',
    #   :from => '',
    #   :fromname => '',
    #   :to => '',
    #   :subject => '',
    #   :html => ''
    # }

    def send data, type=:common

      urls = {
        :common => '/mail.send.json',
        :template => '/mail.send_template.json'
      }

      data.merge! @auth

      res_body = JSON.parse @http_client[urls[type]].post(data).body

      unless res_body['message'].eql? 'success'
        raise res_body['errors'].first
      end

      true

    end

  end
end
