module API
  module V1_6
    class BigV < Grape::API
      before do
        authenticate!
      end

      resources :big_v do
        desc '列表'
        params do
          requires :page, type: Integer
          optional :name, type: String
          optional :app_city, type: String
          optional :job_info, type: String
          optional :profession, type: String
          optional :brief, type: String
        end
        post 'update_profile' do
          present :error, 0
          present :tags, tags, with: API::V1::Entities::TagEntities::Summary
        end
      end
    end
  end
end
