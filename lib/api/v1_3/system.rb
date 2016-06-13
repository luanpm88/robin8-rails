module API
  module V1_3
    class System < Grape::API
      resources :system do
        get 'config' do
          present :error, 0
          present :identify_enabled, Rails.application.secrets[:identify_enabled]
          present :weibo_analysis_enabled, Rails.application.secrets[:weibo_analysis_enabled]
        end
      end
    end
  end
end
