module Brand
  module V2
    module Entities
      class Tag < Entities::Base
        expose :id
        expose :name
        expose :label
      end
    end
  end
end
