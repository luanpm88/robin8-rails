module API
  module V1
    class Tags < Grape::API
      resources :campaigns do
        get 'list' do
        end
      end
    end
  end
end
