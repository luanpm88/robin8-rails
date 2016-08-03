module API
  module V1_6
    module Entities
      module KolKeywordEntities
        class Summary < Grape::Entity
          expose :keyword, :weight
        end
      end
    end
  end
end
