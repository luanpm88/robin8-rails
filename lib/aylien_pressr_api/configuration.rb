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
  module Configuration
    VALID_CONNECTION_KEYS = [:base_uri, :user_agent, :method].freeze
    VALID_OPTIONS_KEYS    = [:username, :password].freeze
    VALID_CONFIG_KEYS     = VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

    DEFAULT_BASE_URI    = 'http://robin8.cloudhub.io/api/v1/'.freeze
    DEFAULT_METHOD      = :get
    DEFAULT_USER_AGENT  = "Aylien Pressr API Ruby Gem #{AylienPressrApi::VERSION}".freeze

    DEFAULT_USERNAME       = nil
    DEFAULT_PASSWORD       = nil

    ENDPOINTS = {
      suggested_authors:  'suggested_authors',
      influencers: 'influencers',
      author_stats: 'authors/:id/stats',
      related_stories: 'suggested_authors/:id/stories',
      authors: 'authors',
      locations_autocompletes: 'autocompletes/locations',
      skills_autocompletes: 'autocompletes/skills',
      author_types_autocompletes: 'autocompletes/author_types',
      stories: 'stories',
      uniq_stories: 'uniq_stories',
      interesting_terms: 'interesting_terms',
      author_update: 'authors/:id'
    }

    # Build accessor methods for every config options so we can do this, for example:
    #   AylienPressrApi.method = :get
    attr_accessor *VALID_CONFIG_KEYS

    # Make sure we have the default values set when we get 'extended'
    def self.extended(base)
      base.reset
    end

    def reset
      self.base_uri     = DEFAULT_BASE_URI
      self.method       = DEFAULT_METHOD
      self.user_agent   = DEFAULT_USER_AGENT

      self.username     = DEFAULT_USERNAME
      self.password     = DEFAULT_PASSWORD
    end

    def configure
      yield self
    end

    def options
      Hash[ * VALID_CONFIG_KEYS.map { |key| [key, send(key)] }.flatten ]
    end
  end # Configuration
end
