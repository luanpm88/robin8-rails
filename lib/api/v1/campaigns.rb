module API
  module V1
    class Tags < Grape::API
      resources :campaigns do
        get 'list' do

        end

        get ':id/receive_task'


        end
      end
    end
  end
end
