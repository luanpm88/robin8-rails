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
      represent Creation,            with: Entities::Creation
      represent CreationSelectedKol, with: Entities::Kol
      represent Tender,              with: Entities::Tender

      # namespaces
      #

      mount CreationsAPI
      mount KolsAPI
      mount UsersAPI
      mount TendersAPI
      mount BaseInfosAPI
      mount SessionsAPI
      mount CodesAPI
      mount TransactionsAPI
      mount CreationSelectedKolsAPI
    end
  end
end
