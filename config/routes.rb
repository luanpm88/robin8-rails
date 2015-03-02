require 'sidekiq/web'
require 'sidetiq/web'
Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  devise_for :users, controllers: { sessions: "users/sessions",
      registrations: "users/registrations", passwords: "users/passwords",
      invitations: "users/invitations",  omniauth_callbacks: "users/omniauth_callbacks",
      confirmations: "users/confirmations" }

  get '/users/manageable_users' => 'users#manageable_users'
  delete '/users/delete_user' => 'users#delete_user'
  get 'users/get_current_user' => 'users#get_current_user'
  delete '/users/disconnect_social' => 'users#disconnect_social'
  post '/users/follow' => 'users#follow'

  resources :posts do
    put 'update_social', on: :member
  end
  resources :news_rooms do
    get 'preview', on: :collection
  end
  resources :industries, only: :index
  resources :releases
  get 'users/identities' => 'users#identities'

  resources :streams, only: [:index, :create, :update, :destroy, :order] do
    post 'order', on: :collection
    get 'stories', on: :member
  end

  get 'autocompletes/topics', to: 'robin_api#proxy'
  get 'autocompletes/blogs',  to: 'robin_api#proxy'
  post 'robin8_api/suggested_authors', to: 'robin_api#suggested_authors'
  get 'robin8_api/influencers', to: 'robin_api#influencers'
  
  post 'textapi/classify'
  post 'textapi/concepts'
  post 'textapi/summarize'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  constraints(Subdomain) do
    get '/' => 'news_rooms#preview'
  end
  # root 'pages#home'
  get '/signup', to: 'pages#signup'
  authenticated :user do
    root to: "pages#home", as: :root
  end

  unauthenticated do
    root to: "pages#landing_page", as: :unauthenticated_root
  end

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
