module Brand
  module V2
    module Entities
      class CreationsTerrace < Entities::Base
        expose :terrace_id, :exposure_value

        expose :name do |object|
          object.terrace.name
        end
        
        expose :short_name do |object|
          object.terrace.short_name
        end

        expose :avatar do |object|
          object.terrace.address
        end

      end
    end
  end
end
