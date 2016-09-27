require 'sidekiq/web'

%w(admin crm).each do |route_name|
  load "#{Rails.root}/config/routes/#{route_name}.rb"
end

Rails.application.routes.draw do
  mount Crm::Engine, at: "/crm"
  # mount StatusPage::Engine, at: '/'
  mount Sidekiq::Web => '/sidekiq'
  mount OpenAPI => '/api', as: :open_api, constraints: {subdomain: 'open'}
  mount API::Application => '/api'
  mount RuCaptcha::Engine => "/rucaptcha"
  mount BrandAPI => '/brand_api'
  mount PropertyAPI => '/prop'
  use_doorkeeper

  get 'track_urls/:id', to: "pages#track_url"

  get 'qiniu_upload_token', to: 'brand#qiniu'
  get 'brand/(/*all)/', to: "brand#index"
  get "brand", to: "brand#index"

  get 'campaign_visit' => "campaign_show#visit"
  get 'campaign_show' => "campaign_show#show"
  get 'campaign_share' => "campaign_show#share"
  get 'read_hot_item' => 'commons#read_hot_item'
  get 'commons/material' =>  'commons#material'


  get "cps_articles/:id" => "cps_articles#show"
  get "cps_article_shares/:id" => "cps_articles#share_show"

  resources :identities do
    member do
      get 'current_categories'
    end
  end
  put 'identities/:id' => "identities#update"
  get 'identities/influence/:id' => 'identities#influence'
  get 'identities/discover/:labels' => 'identities#discover'
  get 'identities/labels/:user_id' => 'identities#labels'

  get 'articles/:id/show' => "articles#show"

  get 'campaign_invite/interface/:type' => 'campaign_invite#interface'
  get 'campaign_invite_by_campaign/:campaign_id' => 'campaign_invite#find_by_hl_and_campaign'
  get 'mark_as_running/:id' => 'campaign_invite#mark_as_running'
  get "campaign/valid_campaigns" => "campaign#valid_campaigns"
  get "campaign/campaign_targets" => "campaign#campaign_targets"

  match '/wechat_third/notify', :via => [:get, :post]
  match '/wechat_third/:appid/callback' => "wechat_third#callback", :via => [:get, :post]

  # devise_for :admin_users, controllers: {
  #   sessions: 'admin_users/sessions'
  # }

  # very slow, don't load it in development env
  #unless Rails.env.development?
    # devise_for :admin_users, ActiveAdmin::Devise.config
    # ActiveAdmin.routes(self)
  #end

  devise_for :admin_users, controllers: {
    sessions: 'admin_users/sessions'
  }

  get    '/users/sign_in', to: redirect('/login')
  get    '/users/sign_up', to: redirect('/register')

  devise_for :users

  devise_scope :user do
    get    '/register',           to: "users/registrations#new"
    post   '/register',           to: "users/registrations#create"
    get    '/register/bind',      to: "users/registrations#bind"
    get    '/register/edit',      to: "users/registrations#edit"
    put    '/register',           to: "users/registrations#update"
    get    '/login',              to: "users/sessions#new"
    get    '/login/scan',         to: "users/sessions#scan"
    get    '/login/scan/submit',  to: "users/sessions#scan_submit"
    post   '/login',              to: "users/sessions#create"
    get    '/logout',             to: "users/sessions#destroy"
    get    '/password',           to: "users/passwords#new"
    post   '/password',           to: "users/passwords#create"
    post   '/passport/sender/sms',to: "users/sessions#sms"
    mount ActionCable.server => '/passport/scan/cable'
  end

  get "/auth/:action/callback", to: "authentications#:action", constraints: { action: /weibo|wechat|qq_connect/ }
  match "/auth/wechat_third" => "authentications#wechat_third", :via => [:get, :post]
  match "/auth/wechat_third_callback" => "authentications#wechat_third_callback", :via => [:get, :post]

  get "/auth/:action/callback", to: "authentications#:action", constraints: { action: /weibo|wechat|qq_connect/ }

  get 'set_locale' => 'pages#set_locale'
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
  get 'kol_value' => 'kols#kol_value'

  # kols
  devise_for :kols, controllers: {
    registrations: "kols/registrations",
    sessions: "users/sessions",
    passwords: "kols/passwords",
    # omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :users do
    collection do
      get 'get_user_by_token'
      get 'identities'
      get 'get_identities'
      get 'info'
      get 'get_avail_amount'
      get :avail_amount
      get :check_exist_by_mobile_number
      post :modify_password
    end
  end

  resources :payments do
    post 'create_subscription', on: :collection
    post 'update_subscription', on: :collection
    delete 'destroy_subscription', on: :collection
    delete 'destroy_add_on',on: :member
  end

  resources :alerts, only: [:create, :show, :update]
  resources :contacts, only: [:index, :create, :show]
  resources :export_influencers, only: [:create]

  get 'share_by_email/show'
  post 'share_by_email' => 'share_by_email#create'

  get 'home', to: 'pages#moments'
  get 'kols', to: 'pages#kols'
  get 'brands/bigv', to: 'pages#bigv'
  get 'brands/moments', to: 'pages#moments'

  root 'pages#home'

  get '/pages/check_used_to_signed_in', to: 'pages#check_used_to_signed_in'
  get '/pages/scan_qr_code_and_login', to: 'pages#scan_qr_code_and_login'
  get '/about', to: 'pages#about'
  get '/team', to: 'pages#team'
  get '/terms', to: 'pages#terms'
  get '/privacy_policy', to: 'pages#privacy_policy'
  get '/contact', to: 'pages#contact'
  post '/contact', to: 'pages#contact'
  get '/contact_us', to: "pages#contact_us"
  match '/withdraw_apply', to: 'pages#withdraw_apply', :via => [:get, :post]
  get '/download_invitation', to: 'pages#download_invitation'
  get '/invite', to: 'pages#invite'
  get '/kol_publish_campaign_help', to: 'pages#kol_publish_campaign_help'
  resources :campaign, only: [:index, :create, :update, :show]
  resources :registered_invitations do
    post :sms, on: :collection
  end

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
