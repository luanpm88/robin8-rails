module Brand
  module V1
    module Entities
      class Profession < Entities::Base
        expose :id
        expose :name
        expose :label
        expose :position
      end
    end
  end
end