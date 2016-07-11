module API
  module V1_5
    class HotItems < Grape::API
      resources :hot_items do

        params do
          optional :page, type: Integer
        end
        get '/' do
          hot_items  = HotItem.all.order('publish_at desc').page(params[:page]).per_page(10)
          present :error, 0
          present :hot_items, hot_items, with: API::V1_5::Entities::HotItemEntities::Summary
        end
      end
    end
  end
end
