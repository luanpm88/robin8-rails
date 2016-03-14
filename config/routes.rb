require 'sidekiq/web'

Rails.application.routes.draw do

  get 'hello_world', to: 'hello_world#index'
  mount Sidekiq::Web => '/sidekiq'
  mount API::Application => '/api'
  mount RuCaptcha::Engine => "/rucaptcha"
  mount ApplicationAPI => '/brand/brand_api'

  get "react/(/*all)/", to: "react#index"
  get "react_fake_data/campaigns", to: 'react#campaigns'
  post "react_fake_data/campaigns", to: 'react#create_campaigns'


  get 'brand', to: "brand#index"

  get 'campaign_show' => "campaign_show#show"
  get 'campaign_share' => "campaign_show#share"

  resources :identities do
    member do
      get 'current_categories'
    end
  end
  put 'identities/:id' => "identities#update"
  get 'identities/influence/:id' => 'identities#influence'
  get 'identities/discover/:labels' => 'identities#discover'
  get 'identities/labels/:user_id' => 'identities#labels'

  resources :discover_records, only: [:create]

  get 'campaign_invite/interface/:type' => 'campaign_invite#interface'
  get 'campaign_invite_by_campaign/:campaign_id' => 'campaign_invite#find_by_kol_and_campaign'
  get 'mark_as_running/:id' => 'campaign_invite#mark_as_running'

  match '/wechat_third/notify', :via => [:get, :post]
  match '/wechat_third/:appid/callback' => "wechat_third#callback", :via => [:get, :post]

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    invitations: "users/invitations",
    omniauth_callbacks: "users/omniauth_callbacks",
    confirmations: "users/confirmations"
  }

  devise_scope :user do
    match "users/auth/wechat_third" => "users/omniauth_callbacks#wechat_third", :via => [:get, :post]
    match "users/auth/wechat_third_callback" => "users/omniauth_callbacks#wechat_third_callback", :via => [:get, :post]
  end

  resources :cn_recommendations
  get 'recommendations/analyse_tweets' => 'recommendations#analyse_tweets'
  get 'recommendations/index' => 'recommendations#index'
  match "recommendations/status/:id" => "recommendations#status", :via => :get
  post 'recommendations/event' => 'recommendations#event'

  get 'pricing' => 'pages#pricing'
  get 'set_locale' => 'pages#set_locale'
  get 'subscribe/:slug' => 'payments#new'
  post 'subscribe/:slug' => 'payments#new'
  get 'upgrade/:slug' => 'payments#edit'
  get 'change_card_info' => 'blue_snap#change_card_info'
  post 'change_card_info' => 'blue_snap#update_card_info'
  get 'change_campaign_card_info' => 'blue_snap#change_campaign_card_info'
  post 'change_campaign_card_info' => 'blue_snap#update_campaign_card_info'
  get '/users/manageable_users' => 'users#manageable_users'
  delete '/users/delete_user' => 'users#delete_user'
  delete '/users/delete_kols_list' => 'kols_lists#delete_kols_list'
  get 'users/get_current_user' => 'users#get_current_user'
  get 'users/get_active_subscription' => 'users#get_active_subscription'
  get 'users/private_kol' => 'users#get_private_kols'
  get 'users/kols_lists' => 'kols_lists#get_contacts_list'
  get 'users/qiniu_uptoken' => 'users#qiniu_uptoken'
  post "users/set_avatar_url" => 'users#set_avatar_url'
  post 'users/import_kols' => 'kols_lists#create'
  post 'users/import_kol' => 'users#import_kol'
  get 'payments/apply_discount' => 'payments#apply_discount'
  get 'payments/check_tax_rate' => 'payments#check_tax_rate'
  delete '/users/disconnect_social' => 'users#disconnect_social'
  # resources :blue_snap
  # resources :payments do
  #
  # end
  post '/users/follow' => 'users#follow'
  post '/users/new' => 'users#create'
  post '/kols/new' => 'kols#create'
  post '/kols/send_sms/' => 'kols#send_sms'
  post '/kols/valid_verify_code/' => 'kols#valid_verify_code'
  get "kols/create_kol_from_social_account" => "kols#create_kol_from_social_account", as: "create_kol_from_social_account"
  get '/users/new' => 'users#new'
  get '/kols/new' => 'kols#create'
  put '/kols/monetize' => 'kols#update_monetize'
  get 'kols/resend_confirmation_mail' => 'kols#resend_confirmation_mail'
  get '/kols/valid_phone_number'

  # kols
  devise_for :kols, controllers: {
    registrations: "kols/registrations",
    sessions: "users/sessions",
    passwords: "kols/passwords"
  }
  get '/kols/get_current_kol' => 'kols#get_current_kol'
  get '/kols/current_categories' => 'kols#current_categories'
  get '/kols/suggest_categories' => 'kols#suggest_categories'
  get '/kols/suggest' => 'kols#suggest_kols'
  get '/kols/get_attachments' => 'kols#get_attachments'
  get '/kols/get_categories_labels' => 'kols#categories_labels'
  get '/kols/get_social_list'
  get '/kols/get_score'

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
  get '/articles/:code' => "public_news_rooms#article"
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
      get 'get_avail_amount'
      get :avail_amount
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

  resources :alerts, only: [:create, :show, :update]
  resources :media_lists, only: [:index, :create, :show, :destroy]
  resources :contacts, only: [:index, :create, :show]
  resources :pitches, only: [:index, :create, :update, :show]
  resources :draft_pitches
  resources :pitches_contacts, only: [:index, :create, :update, :show, :destroy]
  resources :test_emails, only: [:create, :show]
  resources :iptc_categories, only: [:index, :show]
  resources :export_influencers, only: [:create]
  resources :autocompletes, only: [] do
    collection do
      get 'locations'
      get 'skills'
      get 'iptc_categories'
      get 'category'
      get 'author_types'
    end
  end

  get 'share_by_email/show'
  post 'share_by_email' => 'share_by_email#create'

  get 'autocompletes/topics', to: 'robin_api#proxy'
  get 'autocompletes/blogs',  to: 'robin_api#proxy'
  post 'robin8_api/suggested_authors', to: 'robin_api#suggested_authors'
  post 'robin8_api/filter_authors', to: 'robin_api#filtered_authors'
  post 'robin8_api/related_stories', to: 'robin_api#related_stories'
  get 'robin8_api/influencers', to: 'robin_api#influencers'
  get 'robin8_api/authors', to: 'robin_api#authors'
  get 'robin8_api/authors/:id/stats', to: 'robin_api#author_stats'
  get 'robin8_api/stories', to: 'robin_api#stories'
  get '/home', to: 'pages#landing_page_brand'

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
  get '/screenshot_sample', to: 'pages#screenshot_sample'
  get '/unsubscribe', to: 'pages#unsubscribe'
  get '/add-ons', to: 'pages#add_ons'
  get '/payment-confirmation', to: 'pages#payment_confirmation'
  get '/contact_us', to: "pages#contact_us"
  match '/withdraw_apply', to: 'pages#withdraw_apply', :via => [:get, :post]

  resources :campaign, only: [:index, :create, :update, :show]
  get 'campaign/:id/article', to: 'campaign#article'
  get 'campaign/:id/article/:article_id', to: 'campaign#article'
  put 'campaign/:id/article', to: 'campaign#update_article'
  put 'campaign/:id/article/:article_id', to: 'campaign#update_article'
  get 'campaign/:id/article/:article_id/comments', to: 'campaign#article_comments'
  get 'campaign/:id/article/:article_id/wechat_performance', to: 'campaign#wechat_performance'
  post 'campaign/:id/article/:article_id/comments', to: 'campaign#create_article_comment'
  post 'campaign/:id/article/:article_id/wechat_performance', to: 'campaign#create_wechat_performance'
  post 'campaign/wechat_report/claim', to: 'campaign#claim_article_wechat_performance'
  post 'campaign/negotiate_campaign/negotiate', to: 'campaign#negotiate_campaign'
  post 'campaign/:id/article/:article_id/approve', to: 'campaign#approve_article'
  post 'campaign/add_budget', to: 'campaign#add_budget'
  post 'campaign/get_counter', to: 'campaign#get_counter'
  post 'campaign/:id/article/:article_id/approve_request', to: 'campaign#approve_request'
  post 'campaign/test_email', to: 'campaign#test_email'
  get  'campaign/:id/day_stats', to: 'campaign#day_stats'
  get  'campaign/:id/kol_list', to: 'campaign#kol_list'
  resources :campaign_invite, only: [:index, :create, :show, :update]
  post 'campaign_invite/change_invite_status', to: 'campaign_invite#update'
  post 'campaign_invite/change_img_status', to: 'campaign_invite#change_img_status'
  post 'campaign_invite/change_multi_img_status', to: 'campaign_invite#change_multi_img_status'
  resources :kols_lists, only: [:index, :create, :show, :update]

  get '/geocode/country', to: 'geocode#get_country'
  post 'campaign_invite/reject', to: 'interested_campaigns#update'
  post 'campaign_invite/invite', to: 'interested_campaigns#update'
  post 'campaign_invite/ask_for_invite', to: 'interested_campaigns#ask_for_invite'
end
