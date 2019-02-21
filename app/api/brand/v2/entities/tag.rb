module Brand
  module V2
    module Entities
      class Tag < Entities::Base
        expose :id, :name, :label
      end
    end
  end
end
