# Copyright 2015 Aylien, Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module AylienPressrApi
  # The Client class is the main class for calling Pressr API endpoints
  class Client
    attr_accessor *Configuration::VALID_CONFIG_KEYS

    # Creates a Client object.
    # @param [Hash] options Configuration params
    # @option options [String] :app_id The APP_ID
    # @option options [String] :app_key The APP_KEY
    # @option options [String] :base_uri ('https://api.aylien.com/api/v1/')
    #   An URL that points to the Aylien Pressr API
    # @option options [Symbol] :method (:post) Request method.
    # @option options [String] :user_agent Request user-agent
    def initialize(options={})
      merged_options = AylienPressrApi.options.merge(options)

      Configuration::VALID_CONFIG_KEYS.each do |key|
        send("#{key}=", merged_options[key])
      end
    end
    
    def suggested_authors!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params, 
        Configuration::ENDPOINTS[:suggested_authors])
      Connection.new(endpoint, params, config).request!
    end
    
    def influencers!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params, 
        Configuration::ENDPOINTS[:influencers])
      Connection.new(endpoint, params, config).request!
    end
    
    def author_stats!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params, 
        Configuration::ENDPOINTS[:author_stats])
      Connection.new(endpoint, params, config).request!
    end
    
    # Destructives methods
    def suggested_authors(value=nil, params={})
      begin
        suggested_authors!(value, params)
      rescue => e
        nil
      end
    end
    
    def influencers(value=nil, params={})
      begin
        influencers!(value, params)
      rescue => e
        nil
      end
    end
    
    def author_stats(value=nil, params={})
      begin
        author_stats!(value, params)
      rescue => e
        nil
      end
    end
    # END Destructives methods

    private

    def validate_uri(value)
      value =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
    end

    def common_endpoint(value, params, endpoint)
      params = value
      config = {}
      Configuration::VALID_CONFIG_KEYS.each do |key|
        config[key] = send(key)
      end
      
      case endpoint
        when Configuration::ENDPOINTS[:suggested_authors]
          config[:method] = :post
        when Configuration::ENDPOINTS[:influencers]
          params["skills[]"] = params.delete("skills") if params.key?("skills")
        when Configuration::ENDPOINTS[:author_stats]
          endpoint = endpoint.scan(/:(\w+)/).inject("") do |memo, item|
            memo = endpoint.gsub(":#{item[0]}", params[item[0].to_sym].to_s)
            memo
          end
      end
      [endpoint, params, config]
    end
  end # Client
end
