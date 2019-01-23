module Brand
  module V2
    module Entities
      class Terrace < Entities::Base
        expose :id
        expose :name
        expose :short_name
        expose :avatar 
        expose :address
      end
    end
  end
end
