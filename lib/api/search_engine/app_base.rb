module API
  module SearchEngine
    class AppBase < API::Application
      version 'search_engine', using: :path
      mount API::SearchEngine::Kols
    end
  end
end
