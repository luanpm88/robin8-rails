module API
  module V1_5
    class Tags < Grape::API
      resources :tags do
        get 'list' do
          tags  = Tag.where("cover_url is not null").order('position desc')
          present :error, 0
          present :tags, tags, with: API::V1::Entities::TagEntities::Summary
        end
      end
    end
  end
end
