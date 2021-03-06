Crm::Engine.routes.draw do
  namespace :v1 do
    resources :sellers, only: [] do
      collection do
        get :account
        get :orders
      end
    end
    namespace :sellers do
      resources :sessions, only: [:index]
    end

    resources :customers

    resources :cases
    resources :notes
  end
end
