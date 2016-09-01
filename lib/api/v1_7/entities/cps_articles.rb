module API
  module V1_7
    module Entities
      module CpsArticles
        class Summary < Grape::Entity
          expose :id, :title, :cover_url, :content, :show_url, :status, :check_remark
        end
      end
    end
  end
end
