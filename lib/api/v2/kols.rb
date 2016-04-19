module API
  module V2
    class Kols < Grape::API
      resources :kols do
        before do
          authenticate!
        end

      end
    end
  end
end
