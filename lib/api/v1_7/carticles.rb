module API
  module V1_7
    class Carticles < Grape::API
      resources :carticles do
        before do
          authenticate!
        end
        #获取活动素材
        params do
          optional :content, type: String
        end
        post '/' do
          article = Carticle.new(:body => params[:content])
          article.save
          present :article, article, with: API::V1_7::Entities::Carticles::Detail
        end
      end
    end
  end
end
