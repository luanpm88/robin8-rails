module Brand
  module V1
    module Entities
      class Kol < Entities::Base
        expose :id, :name, :avatar_url, :influence_score, :city
      end
    end
  end
end
