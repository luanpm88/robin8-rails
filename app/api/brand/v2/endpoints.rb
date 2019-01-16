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
  module V2
    class Endpoints < Base
      version 'v2', using: :path
      formatter :json, SuccessFormatter

      # helpers
      #
      helpers APIHelpers

      # representations
      #
      represent Creation,         with: Entities::Creation

      # namespaces
      #

      mount CreationsAPI
    end
  end
end
