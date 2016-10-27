module API
  module SearchEngine
    module Entities
      module KolEntities
        class SocialAccount < Grape::Entity
          expose :id, as: 'social_account_id'
          expose :provider
          expose :provider_text
          expose :price
        end
      end
    end
  end
end
