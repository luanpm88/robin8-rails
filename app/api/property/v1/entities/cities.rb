module Property
  module V1
    module Entities
      class Cities < Entities::Base
        expose :id
        expose :name
      end
    end
  end
end
