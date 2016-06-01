module API
  module V1_3
    class Images < Grape::API
      resources :images do
        post 'upload' do
          required_attributes! [:avatar]
          image = Image.new(:avatar => params[:avatar])
          image.save
          return {:error => 0, :image_id =>  image.id }
        end
      end
    end
  end
end
