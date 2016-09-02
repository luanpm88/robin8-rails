module API
  module V1_7
    class AppBase < API::Application
      version 'v1_7', using: :path
      mount API::V1_7::CpsArticles
      # mount API::V1_7::CpsArticleShares
      mount API::V1_7::CpsMaterials
    end
  end
end
