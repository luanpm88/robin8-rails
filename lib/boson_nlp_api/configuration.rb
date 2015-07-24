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
  module Configuration
    VALID_CONNECTION_KEYS = [:base_uri, :user_agent, :method].freeze
    VALID_OPTIONS_KEYS    = [:token].freeze
    VALID_CONFIG_KEYS     = VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

    DEFAULT_BASE_URI    = 'http://api.bosonnlp.com/'.freeze
    DEFAULT_METHOD      = :post
    DEFAULT_USER_AGENT  = "Boson NLP API Ruby Gem #{BosonNlpApi::VERSION}".freeze

    DEFAULT_TOKEN       = nil

    ENDPOINTS = {
      classify:  'classify/analysis'
    }

    # Build accessor methods for every config options so we can do this, for example:
    #   BosonNlpApi.method = :get
    attr_accessor *VALID_CONFIG_KEYS

    # Make sure we have the default values set when we get 'extended'
    def self.extended(base)
      base.reset
    end

    def reset
      self.base_uri     = DEFAULT_BASE_URI
      self.method       = DEFAULT_METHOD
      self.user_agent   = DEFAULT_USER_AGENT

      self.token        = DEFAULT_TOKEN
    end

    def configure
      yield self
    end

    def options
      Hash[ * VALID_CONFIG_KEYS.map { |key| [key, send(key)] }.flatten ]
    end
  end # Configuration
end
