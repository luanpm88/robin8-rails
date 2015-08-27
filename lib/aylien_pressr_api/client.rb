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

    # Destructives methods
    def suggested_authors!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params,
        Configuration::ENDPOINTS[:suggested_authors])
      Connection.new(endpoint, params, config).request!
    end

    def related_stories!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params,
        Configuration::ENDPOINTS[:related_stories])
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

    def authors!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params,
        Configuration::ENDPOINTS[:authors])
      Connection.new(endpoint, params, config).request!
    end

    def author_update!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params,
        Configuration::ENDPOINTS[:author_update])
      Connection.new(endpoint, params, config).request!
    end

    def locations_autocompletes!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params,
        Configuration::ENDPOINTS[:locations_autocompletes])
      Connection.new(endpoint, params, config).request!
    end

    def skills_autocompletes!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params,
        Configuration::ENDPOINTS[:skills_autocompletes])
      Connection.new(endpoint, params, config).request!
    end

    def stories!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params,
        Configuration::ENDPOINTS[:stories])
      Connection.new(endpoint, params, config).request!
    end

    def uniq_stories!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params,
        Configuration::ENDPOINTS[:uniq_stories])
      Connection.new(endpoint, params, config).request!
    end

    def interesting_terms!(value=nil, params={})
      endpoint, params, config = common_endpoint(value, params,
        Configuration::ENDPOINTS[:interesting_terms])
      Connection.new(endpoint, params, config).request!
    end
    # END Destructives methods


    def suggested_authors(value=nil, params={})
      begin
        suggested_authors!(value, params)
      rescue => e
        nil
      end
    end

    def related_stories(value=nil, params={})
      begin
        related_stories!(value, params)
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

    def authors(value=nil, params={})
      begin
        authors!(value, params)
      rescue => e
        nil
      end
    end

    def author_update(value=nil, params={})
      begin
        puts params
        author_update!(params, params)
      rescue => e
        puts e
        nil
      end
    end

    def locations_autocompletes(value=nil, params={})
      begin
        locations_autocompletes!(value, params)
      rescue => e
        nil
      end
    end

    def skills_autocompletes(value=nil, params={})
      begin
        skills_autocompletes!(value, params)
      rescue => e
        nil
      end
    end

    def stories(value=nil, params={})
      begin
        stories!(value, params)
      rescue => e
        nil
      end
    end

    def uniq_stories(value=nil, params={})
      begin
        uniq_stories!(value, params)
      rescue => e
        nil
      end
    end

    def interesting_terms(value=nil, params={})
      begin
        interesting_terms!(value, params)
      rescue => e
        nil
      end
    end

    private

    def validate_uri(value)
      value =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
    end

    def common_endpoint(value, params, endpoint)

      params = value.blank? ? {} : value

      config = {}
      Configuration::VALID_CONFIG_KEYS.each do |key|
        config[key] = send(key)
      end

      case endpoint
        when Configuration::ENDPOINTS[:suggested_authors]
          if params.key?("iptc_categories")
            params["iptc_categories[]"] = params.delete("iptc_categories")
          end
          config[:method] = :post
        when Configuration::ENDPOINTS[:interesting_terms]
          config[:method] = :post
        when Configuration::ENDPOINTS[:influencers]
          params["skills[]"] = params.delete("skills") if params.key?("skills")
        when Configuration::ENDPOINTS[:author_stats]
          endpoint = endpoint.scan(/:(\w+)/).inject("") do |memo, item|
            memo = endpoint.gsub(":#{item[0]}", params[item[0].to_sym].to_s)
            memo
          end
        when Configuration::ENDPOINTS[:related_stories]
          config[:method] = :post
          if params.key?("iptc_categories")
            params["iptc_categories[]"] = params.delete("iptc_categories")
          end
          endpoint = endpoint.scan(/:(\w+)/).inject("") do |memo, item|
            memo = endpoint.gsub(":#{item[0]}", params[item[0].to_sym].to_s)
            memo
          end
        when Configuration::ENDPOINTS[:authors]
          params["keywords[]"] = params.delete("keywords") if params.key?("keywords")
        when Configuration::ENDPOINTS[:stories]
          params["author_ids[]"] = params.delete("author_ids") if params.key?("author_ids")
          params["blog_ids[]"] = params.delete("blog_ids") if params.key?("blog_ids")
          params["facet_fields[]"] = params.delete("facet_fields") if params.key?("facet_fields")
          params["group_fields[]"] = params.delete("group_fields") if params.key?("group_fields")
          params["iptc_categories[]"] = params.delete("iptc_categories") if params.key?("iptc_categories")
          params["iptc_categories_level_1[]"] = params.delete("iptc_categories_level_1") if params.key?("iptc_categories_level_1")
          params["iptc_categories_level_2[]"] = params.delete("iptc_categories_level_2") if params.key?("iptc_categories_level_2")
          params["iptc_categories_level_3[]"] = params.delete("iptc_categories_level_3") if params.key?("iptc_categories_level_3")
          params["keywords[]"] = params.delete("keywords") if params.key?("keywords")
          params["topics[]"] = params.delete("topics") if params.key?("topics")
        when Configuration::ENDPOINTS[:uniq_stories]
          params["author_ids[]"] = params.delete("author_ids") if params.key?("author_ids")
          params["blog_ids[]"] = params.delete("blog_ids") if params.key?("blog_ids")
          params["iptc_categories[]"] = params.delete("iptc_categories") if params.key?("iptc_categories")
          params["iptc_categories_level_1[]"] = params.delete("iptc_categories_level_1") if params.key?("iptc_categories_level_1")
          params["iptc_categories_level_2[]"] = params.delete("iptc_categories_level_2") if params.key?("iptc_categories_level_2")
          params["iptc_categories_level_3[]"] = params.delete("iptc_categories_level_3") if params.key?("iptc_categories_level_3")
          params["keywords[]"] = params.delete("keywords") if params.key?("keywords")
          params["topics[]"] = params.delete("topics") if params.key?("topics")
        when Configuration::ENDPOINTS[:author_update]
          config[:method] = :put
          endpoint = endpoint.scan(/:(\w+)/).inject("") do |memo, item|
            memo = endpoint.gsub(":#{item[0]}", params[item[0].to_sym].to_s)
            memo
          end
      end
      [endpoint, params, config]
    end
  end # Client
end
