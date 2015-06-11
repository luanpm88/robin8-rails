require 'sidekiq/web'
require 'sidetiq/web'
Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  mount Sidekiq::Web => '/sidekiq'
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    invitations: "users/invitations",
    omniauth_callbacks: "users/omniauth_callbacks",
    confirmations: "users/confirmations"
  }

  get 'pricing' => 'pages#pricing'
  get 'set_locale' => 'pages#set_locale'
  get 'subscribe/:slug' => 'payments#new'
  post 'subscribe/:slug' => 'payments#new'
  get 'upgrade/:slug' => 'payments#edit'
  get 'change_card_info' => 'blue_snap#change_card_info'
  post 'change_card_info' => 'blue_snap#update_card_info'
  get '/users/manageable_users' => 'users#manageable_users'
  delete '/users/delete_user' => 'users#delete_user'
  get 'users/get_current_user' => 'users#get_current_user'
  get 'users/get_active_subscription' => 'users#get_active_subscription'
  get 'payments/apply_discount' => 'payments#apply_discount'
  delete '/users/disconnect_social' => 'users#disconnect_social'
  # resources :blue_snap
  # resources :payments do
  #
  # end
  post '/users/follow' => 'users#follow'
  post '/users/new' => 'users#create'

  resources :posts do
    put 'update_social', on: :member
    get 'tomorrows', on: :collection
    get 'others', on: :collection
  end
  resources :news_rooms do
    get 'web_analytics'
    get 'email_analytics'
  end
  resource :public_news_room do
    resources :followers, only: [:new, :create]
    get 'presskit'
  end
  resources :preview_news_rooms, only: [:index, :create, :show, :update, :destroy]
  resources :industries, only: :index
  resources :releases do
    post 'extract_from_word', on: :collection
    get 'img_url_exist', on: :collection
  end
  resources :users do
    collection do
      get 'identities'
      get 'get_identities'
      get 'info'
    end
  end

  resources :streams, only: [:index, :create, :update, :destroy, :order] do
    post 'order', on: :collection
    get 'stories', on: :member
  end

  resources :products, only: [:index] do
  end

  resources :payments do
    post 'create_subscription', on: :collection
    post 'update_subscription', on: :collection
    delete 'destroy_subscription', on: :collection
    delete 'destroy_add_on',on: :member
  end

  resources :media_lists, only: [:index, :create, :show, :destroy]
  resources :contacts, only: [:index, :create, :show]
  resources :pitches, only: [:index, :create, :show]
  resources :draft_pitches
  resources :pitches_contacts, only: [:index, :create, :show, :destroy]
  resources :iptc_categories, only: [:index]
  resources :export_influencers, only: [:create]
  resources :autocompletes, only: [] do
    collection do
      get 'locations'
      get 'skills'
      get 'iptc_categories'
    end
  end

  get 'share_by_email/show'
  post 'share_by_email' => 'share_by_email#create'

  get 'autocompletes/topics', to: 'robin_api#proxy'
  get 'autocompletes/blogs',  to: 'robin_api#proxy'
  post 'robin8_api/suggested_authors', to: 'robin_api#suggested_authors'
  post 'robin8_api/related_stories', to: 'robin_api#related_stories'
  get 'robin8_api/influencers', to: 'robin_api#influencers'
  get 'robin8_api/authors', to: 'robin_api#authors'
  get 'robin8_api/authors/:id/stats', to: 'robin_api#author_stats'
  get 'robin8_api/stories', to: 'robin_api#stories'

  post 'textapi/classify'
  post 'textapi/concepts'
  post 'textapi/summarize'
  post 'textapi/extract'
  post 'textapi/hashtags'

  get 'image_proxy' => 'image_proxy#get', as: 'image_proxy'
  
  constraints(Subdomain) do
    get '/' => 'public_news_rooms#show', as: :subdomain_root
  end

  root 'pages#home'

  get '/signup', to: 'pages#signup'
  get '/signin', to: 'pages#signin'
  get '/about', to: 'pages#about'
  get '/team', to: 'pages#team'
  get '/terms', to: 'pages#terms'
  get '/contact', to: 'pages#contact'
  post '/contact', to: 'pages#contact'
  get '/add-ons', to: 'pages#add_ons'
  get '/payment-confirmation', to: 'pages#payment_confirmation'

end
