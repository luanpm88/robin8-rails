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

module BosonNlpApi
  # The Client class is the main class for calling Boson NLP API endpoints
  class Client
    attr_accessor *Configuration::VALID_CONFIG_KEYS

    # Creates a Client object.
    # @param [Hash] options Configuration params
    # @option options [String] :token The TOKEN
    # @option options [String] :base_uri ('http://api.bosonnlp.com/')
    #   An URL that points to the Boson NLP API
    # @option options [Symbol] :method (:post) Request method.
    # @option options [String] :user_agent Request user-agent
    def initialize(options={})
      merged_options = BosonNlpApi.options.merge(options)

      Configuration::VALID_CONFIG_KEYS.each do |key|
        send("#{key}=", merged_options[key])
      end
    end
    
    # Destructives methods
    def classify!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params, 
        Configuration::ENDPOINTS[:classify])
      Connection.new(endpoint, params, config).request!
    end
    
    def tag!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params, 
        Configuration::ENDPOINTS[:tag])
      Connection.new(endpoint, params, config).request!
    end
    
    def ner!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params, 
        Configuration::ENDPOINTS[:ner])
      Connection.new(endpoint, params, config).request!
    end
    # END Destructives methods
    
    
    def classify(value=nil, params={})
      begin
        classify!(value, params)
      rescue => e
        nil
      end
    end
    
    def tag(value=nil, params={})
      begin
        tag!(value, params)
      rescue => e
        nil
      end
    end
    
    def ner(value=nil, params={})
      begin
        ner!(value, params)
      rescue => e
        nil
      end
    end
    
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
      
      [endpoint, params, config]
    end
  end # Client
end
