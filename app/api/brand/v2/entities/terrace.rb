module Brand
  module V2
    module Entities
      class Terrace < Entities::Base
        expose :id, :name, :short_name, :address
        expose :avatar do |object|
          object.address
        end
      end
    end
  end
end
