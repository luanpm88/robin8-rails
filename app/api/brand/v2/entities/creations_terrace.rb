module Brand
  module V2
    module Entities
      class CreationsTerrace < Entities::Base
        expose :name do |object, opts|
          object.terrace.name
        end
        expose :exposure_value do |object, opts|
          object.terrace.exposure_value
        end
        expose :exposure_value 
      end
    end
  end
end
