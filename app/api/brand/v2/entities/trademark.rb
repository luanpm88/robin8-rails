module Brand
  module V2
    module Entities
      class Trademark < Entities::Base
        expose :id, :name, :description, :status

      end
    end
  end
end
