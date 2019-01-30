module Brand
  module V2
    module Entities
      class Terrace < Entities::Base
        expose :id, :name, :short_name, :avatar, :address
      end
    end
  end
end
