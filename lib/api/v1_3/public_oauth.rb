module API
  module V1_3
    class PublicOauth < Grape::API
      resources :public_oauth do
        before do
          authenticate!
        end

        get 'get_qrcode' do
        end
      end
    end
  end
end
