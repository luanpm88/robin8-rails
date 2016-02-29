module API
  module V1
    module Entities
      module IdentityEntities
        class Summary < Grape::Entity
          expose :provider, :uid, :token, :name, :url, :avatar_url, :desc
        end
      end
    end
  end
end
