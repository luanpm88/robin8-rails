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
      end
    end
  end
end
