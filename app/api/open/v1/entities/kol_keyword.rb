module Open
  module V1
    module Entities
      module KolKeyword
        class Summary < Grape::Entity
          expose :keyword, :weight
        end
      end
    end
  end
end
