module API
  module V1_6
    class My < Grape::API
      resources :my do
        before do
          authenticate!
        end

        get 'show' do
          present :error, 0
          present :kol, current_kol, with: API::V1_6::Entities::BigVEntities::My
        end

        params do
          optional :page, type: Integer
        end
        get 'friends' do
          current_kol.friends.page(params[:page]).per_page(10)
          present :error, 0
          present :friends, friends, with: API::V1_6::Entities::BigVEntities::Summary
        end
      end
    end
  end
end
