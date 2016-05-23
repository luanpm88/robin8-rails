module API
  module V1_3
    module Entities
      module KolIdentityPriceEntities
        class Summary  < Grape::Entity
          expose :provider, :name, :follower_count, :belong_field, :headline_price, :second_price, :single_price
        end
      end
    end
  end
end
