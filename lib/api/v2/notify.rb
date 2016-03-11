module API
  module V2
    class Notify < Grape::API
      resources :notify do
        get 'reset_elastic_index' do

        end

      end
    end
  end
end
