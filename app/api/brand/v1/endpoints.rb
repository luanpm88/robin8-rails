module SuccessFormatter
  def self.call obj, env
    if obj.is_a? Array
      {
        :items => obj,
        :paginate => env['api.endpoint'].header
      }
    else
      obj
    end.to_json
  end
end

module Brand
  module V1
    class Endpoints < Base
      version 'v1', using: :path
      formatter :json, SuccessFormatter

      # helpers
      #
      helpers APIHelpers

      # representations
      #
      represent Campaign, with: Entities::Campaign

      # namespaces
      #
      namespace 'user', desc: 'Operations about current user' do
        mount UserAPI
      end

      mount CampaignsAPI
    end
  end
end
