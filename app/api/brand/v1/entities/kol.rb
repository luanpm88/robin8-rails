module Brand
  module V1
    module Entities
      class Kol < Entities::Base
        expose :id, :name, :avatar_url
      end
    end
  end
end