require 'sidekiq/web'

%w(admin).each do |route_name|
  load "#{Rails.root}/config/routes/#{route_name}.rb"
end

Rails.application.routes.draw do
  mount StatusPage::Engine, at: '/'
  mount Sidekiq::Web => '/sidekiq'
  mount API::Application => '/api'
  mount RuCaptcha::Engine => "/rucaptcha"
  mount ApplicationAPI => '/brand_api'

  get 'track_urls/:id', to: "pages#track_url"

  get 'qiniu_upload_token', to: 'brand#qiniu'
  get 'brand/(/*all)/', to: "brand#index"
  get "brand", to: "brand#index"

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

  get 'articles/:id/show' => "articles#show"

  get 'campaign_invite/interface/:type' => 'campaign_invite#interface'
  get 'campaign_invite_by_campaign/:campaign_id' => 'campaign_invite#find_by_kol_and_campaign'
  get 'mark_as_running/:id' => 'campaign_invite#mark_as_running'

  match '/wechat_third/notify', :via => [:get, :post]
  match '/wechat_third/:appid/callback' => "wechat_third#callback", :via => [:get, :post]

  # devise_for :admin_users, controllers: {
  #   sessions: 'admin_users/sessions'
  # }

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
    passwords: "kols/passwords"
  }

  resources :users do
    collection do
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

  get '/home', to: 'pages#home'

  root 'pages#home'

  get '/signup', to: 'pages#signup'
  get '/signin', to: 'pages#signin'
  get '/pages/check_used_to_signed_in', to: 'pages#check_used_to_signed_in'
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



  # =========================申请支付宝需要的页面路由用完要删掉=============================
  get 'join_in', to: 'pages#join_in'
  get 'pay', to: 'pages#pay'
end
