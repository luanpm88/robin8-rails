module API
  module V1_7
    class Images < Grape::API
      resources :images do
        before do
          authenticate!
        end
        params do
          requires :file, type: Hash
        end
        post 'upload' do
          uploader = AvatarUploader.new
          uploader.store!(params[:file])
          present :error, 0
          present :url, uploader.url
        end
      end
    end
  end
end
