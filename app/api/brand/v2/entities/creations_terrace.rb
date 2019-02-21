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

      end
    end
  end
end