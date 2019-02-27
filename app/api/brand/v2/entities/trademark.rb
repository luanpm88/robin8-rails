module Brand
  module V2
    module Entities
      class Trademark < Entities::Base
        expose :id, :name, :description, :status, :keywords

      end
    end
  end
end
