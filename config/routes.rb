require 'sidekiq/web'
require 'sidetiq/web'
Rails.application.routes.draw do
  resources :media_lists, only: [:index, :create, :show, :destroy]
  resources :contacts, only: [:index, :create, :show]
  resources :pitches, only: [:index, :create, :show]
  resources :pitches_contacts, only: [:index, :create, :show, :destroy]
  resources :iptc_categories, only: [:index]
  resources :autocompletes, only: [] do
    collection do
      get 'locations'
      get 'skills'
    end
  end

  mount Sidekiq::Web => '/sidekiq'
  devise_for :users, controllers: { sessions: "users/sessions",
      registrations: "users/registrations", passwords: "users/passwords",
      invitations: "users/invitations",  omniauth_callbacks: "users/omniauth_callbacks",
      confirmations: "users/confirmations" }

  get 'pricing' => 'pages#pricing'
  get 'subscribe/:slug' => 'subscriptions#new'
  get 'upgrade/:slug' => 'subscriptions#edit'
  get '/users/manageable_users' => 'users#manageable_users'
  delete '/users/delete_user' => 'users#delete_user'
  get 'users/get_current_user' => 'users#get_current_user'
  get 'users/get_active_subscription' => 'users#get_active_subscription'
  delete '/users/disconnect_social' => 'users#disconnect_social'
  # resources :blue_snap
  resources :subscriptions do
    post 'create_subscription', on: :collection
    post 'update_subscription', on: :collection
    delete 'destroy_subscription', on: :collection
  end
  post '/users/follow' => 'users#follow'

  resources :posts do
    put 'update_social', on: :member
  end
  resources :news_rooms do
    get 'preview', on: :collection
    get 'presskit', on: :collection
  end
  resources :industries, only: :index
  resources :releases
  get 'users/identities' => 'users#identities'

  resources :streams, only: [:index, :create, :update, :destroy, :order] do
    post 'order', on: :collection
    get 'stories', on: :member
  end

  resources :packages, only: [:index] do
  end
  resources :payments, only: :index

  get 'autocompletes/topics', to: 'robin_api#proxy'
  get 'autocompletes/blogs',  to: 'robin_api#proxy'
  post 'robin8_api/suggested_authors', to: 'robin_api#suggested_authors'
  post 'robin8_api/related_stories', to: 'robin_api#related_stories'
  get 'robin8_api/influencers', to: 'robin_api#influencers'
  get 'robin8_api/author_stats', to: 'robin_api#author_stats'
  get 'robin8_api/authors', to: 'robin_api#authors'
  
  post 'textapi/classify'
  post 'textapi/concepts'
  post 'textapi/summarize'
  post 'textapi/extract'
  post 'textapi/hashtags'

  post 'followers/add/', to: 'followers#add'

  constraints(Subdomain) do
    get '/' => 'news_rooms#preview'
  end

  root 'pages#home'
  
  get '/signup', to: 'pages#signup'
  get '/signin', to: 'pages#signin'

end
