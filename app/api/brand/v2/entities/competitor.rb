module Brand
  module V2
    module Entities
      class Competitor < Entities::Base
        expose :id, :name, :short_name, :status
      end
    end
  end
end
