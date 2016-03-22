module API
  module V1
    class Configs < Grape::API
      resources :configs do
        get 'identify_enabled' do
          present :error, 0
          present :enabled, Rails.application.secrets[:identify_enabled]
        end

      end
    end
  end
end
