Rails.application.routes.draw do
  namespace :crm_dashboard do
    get '/' => 'dashboard#index'

    resources :sellers do
      member do
        get :customers
        get :orders
      end
    end
    resources :customers

    resources :cases
  end
end