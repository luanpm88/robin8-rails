Rails.application.routes.draw do
  namespace :crm_dashboard do
    get '/' => 'dashboard#index'

    resources :sellers
    resources :customers
  end
end
