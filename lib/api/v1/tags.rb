module API
  module V1
    class Tags < Grape::API
      resources :tags do
        get 'list' do
          tags  = Tag.all.order('position desc')
          present :error, 0
          present :tags, tags, with: API::V1::Entities::TagEntities::Summary
        end
      end
    end
  end
end
