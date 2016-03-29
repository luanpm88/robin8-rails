module SuccessFormatter
  def self.call obj, env
    if obj.is_a? Array and env['api.endpoint'].header
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

      before do
	authenticate!
      end

      # helpers
      #
      helpers APIHelpers

      # representations
      #
      represent User     , with: Entities::User
      represent Campaign , with: Entities::Campaign

      # namespaces
      #
      namespace 'user', desc: 'Operations about current user' do
        mount UserAPI
      end

      namespace 'util', desc: 'Util' do
	mount UtilAPI
      end

      mount CampaignsAPI
    end
  end
end
