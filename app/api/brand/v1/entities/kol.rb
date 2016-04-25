module Brand
  module V1
    module Entities
      class Kol < Entities::Base
        expose :id, :name, :avatar_url, :influence_score
        expose :city do |object|
          object.app_city_label
        end
      end
    end
  end
end
