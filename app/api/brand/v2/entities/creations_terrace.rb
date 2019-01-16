module Brand
  module V2
    module Entities
      class CreationsTerrace < Entities::Base
        expose :terrace, using: Entities::Terrace do |object, opts|
          object.terrace
        end
        expose :exposure_value 
      end
    end
  end
end
