require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  username == 'robin8' && password == 'robin8&admin'
end

%w(admin crm).each do |route_name|
  load "#{Rails.root}/config/routes/#{route_name}.rb"
end

Rails.application.routes.draw do
  mount Crm::Engine, at: "/crm"
  # mount StatusPage::Engine, at: '/'
  mount Sidekiq::Web => '/sidekiq'
  if Rails.env.production?
    # TODO: 要将生产环境的 Open API `open.robin8.net/api/v1` 命名空间迁也移成 `robin8.net/api/open_v1`
    mount OpenAPI => '/api', as: :open_api, constraints: {subdomain: 'open'}
  else
    mount OpenAPI => '/open_api', as: :open_api
  end
  mount API::Application => '/api'
  mount RuCaptcha::Engine => "/rucaptcha"
  mount BrandAPI => '/brand_api'
  mount PropertyAPI => '/prop'
  use_doorkeeper

  get 'track_urls/:id', to: "pages#track_url"

  get 'qiniu_upload_token', to: 'brand#qiniu'
  get 'brand/(/*all)/', to: "brand#index"

  # 网红添加活动和充值的页面
  get "brand", to: "brand#index"

  get 'campaign_visit' => "campaign_show#visit" #无法访问
  get 'campaign_show' => "campaign_show#show"  #不存在
  get 'campaign_share' => "campaign_show#share" #无法访问
  get 'read_hot_item' => 'commons#read_hot_item' #无法访问
  get 'commons/material' =>  'commons#material' #无法访问
  get '/PtVJevFvqY.txt' => 'pages#index'


  get "cps_articles/:id" => "cps_articles#show" #是图文，链接到京东
  get "cps_article_shares/:id" => "cps_articles#share_show"#文章、链接

  #无法访问
  resources :identities do
    member do
      get 'current_categories'
    end
  end

  put 'identities/:id' => "identities#update"
  get 'identities/influence/:id' => 'identities#influence' #无法访问
  get 'identities/discover/:labels' => 'identities#discover'
  get 'identities/labels/:user_id' => 'identities#labels' #无法访问

  get 'articles/:id/show' => "articles#show" #直接跳转到微信公众号文章

  get 'campaign_invite/interface/:type' => 'campaign_invite#interface'
  get 'campaign_invite_by_campaign/:campaign_id' => 'campaign_invite#find_by_hl_and_campaign' #无法访问
  get 'mark_as_running/:id' => 'campaign_invite#mark_as_running' #:id为1时返回error
  get "campaign/valid_campaigns" => "campaign#valid_campaigns" #返回error, api key not right
  get "campaign/campaign_targets" => "campaign#campaign_targets"#返回error, api key not right

  match '/wechat_third/notify', :via => [:get, :post]#get返回success
  match '/wechat_third/:appid/callback' => "wechat_third#callback", :via => [:get, :post]#get返回success

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

  get    '/users/sign_in', to: redirect('/login') #进入登录页面
  get    '/users/sign_up', to: redirect('/register')#注册页面

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
  match "/auth/wechat_third" => "authentications#wechat_third", :via => [:get, :post] #微信公众平台授权登录？
  match "/auth/wechat_third_callback" => "authentications#wechat_third_callback", :via => [:get, :post] #第三方登录？ 返回failure

  get "/auth/:action/callback", to: "authentications#:action", constraints: { action: /weibo|wechat|qq_connect/ }

  get 'set_locale' => 'pages#set_locale'  #redirect_to到root页
  get '/users/manageable_users' => 'users#manageable_users'#返回[]
  delete '/users/delete_user' => 'users#delete_user'
  delete '/users/delete_kols_list' => 'kols_lists#delete_kols_list'
  get 'users/get_current_user' => 'users#get_current_user' #无法访问
  get 'users/get_active_subscription' => 'users#get_active_subscription' #无法访问
  get 'users/private_kol' => 'users#get_private_kols'#返回[],要的是current_user的kols，可能是因为我这个用户的kols就是空的吧？
  get 'users/kols_lists' => 'kols_lists#get_contacts_list'#进入了登录页
  get 'users/qiniu_uptoken' => 'users#qiniu_uptoken' # 产生了一串随机码
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
  #发送验证码
  post '/kols/send_sms/' => 'kols#send_sms'
  #确认验证码
  post '/kols/valid_verify_code/' => 'kols#valid_verify_code'
  get "kols/create_kol_from_social_account" => "kols#create_kol_from_social_account", as: "create_kol_from_social_account" #无法访问
  get '/users/new' => 'users#new' #无法访问
  get '/kols/new' => 'kols#create' #无法访问
  put '/kols/monetize' => 'kols#update_monetize'
  get 'kols/resend_confirmation_mail' => 'kols#resend_confirmation_mail' #error
  get '/kols/valid_phone_number' #false
  get 'kol_value' => 'kols#kol_value' #无法访问

  # kols
  devise_for :kols, controllers: {
    registrations: "kols/registrations",
    sessions: "users/sessions",
    passwords: "kols/passwords",
    # omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :users do
    collection do
      get 'get_user_by_token' #找不到对应的action
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
  resources :contacts, only: [:index, :create, :show] #和后面的路径重复了
  resources :export_influencers, only: [:create]

  get 'share_by_email/show' # 无法访问
  post 'share_by_email' => 'share_by_email#create'

  get 'home', to: 'pages#moments'

  #点击 “我是网红” 得到的画面
  get 'kols', to: 'pages#kols'

  # 点击"我是广告主-寻找大V"
  get 'brands/bigv', to: 'pages#bigv'

  # 点击”我是广告主——朋友圈推广"
  get 'brands/moments', to: 'pages#moments'

  root 'pages#home'

  get '/pages/check_used_to_signed_in', to: 'pages#check_used_to_signed_in'
  get '/pages/scan_qr_code_and_login', to: 'pages#scan_qr_code_and_login'

  get '/about', to: 'pages#about'
  get '/team', to: 'pages#team'
  get '/terms', to: 'pages#terms'
  get '/privacy_policy', to: 'pages#privacy_policy'

  # 在/brands/bigv页面点击 "了解更多" 出现表单
  get '/contact', to: 'pages#contact'
  post '/contact', to: 'pages#contact'
  get '/contact_us', to: "pages#contact_us" #无法访问

  #无法访问
  match '/withdraw_apply', to: 'pages#withdraw_apply', :via => [:get, :post]

  #进入APP下载页面
  get '/download_invitation', to: 'pages#download_invitation'
  get '/invite', to: 'pages#invite' #进入填写手机号、验证码的页面
  get '/kol_publish_campaign_help', to: 'pages#kol_publish_campaign_help' #填写活动帮助说明

  get '/kol_invite', to: 'pages#kol_invite' # admintag邀请成为kol

  get '/pages/pmes_demo', to: 'pages#pmes_demo'

  #无法访问
  resources :campaign, only: [:index, :create, :update, :show]

  #无法访问
  resources :registered_invitations do
    post :sms, on: :collection
    post :kol, on: :collection
  end
  get 'club_campaign/campaign_page'
  get 'club_campaign/kol_register'
  post 'club_campaign/kol_create'
  post 'club_campaign/sms_request'
  get 'club_campaign/campaign_details'
  get 'wechat_campaign/campaign_page'
  get 'wechat_campaign/kol_register'
  post 'wechat_campaign/kol_create'
  post 'wechat_campaign/sms_request'
  get 'wechat_campaign/campaign_details'
  get 'wechat_geometry/kol_register' #成为品牌带盐人
  post 'wechat_geometry/kol_create'
  post 'wechat_geometry/sms_request'

  get 'wechat_geometry/geometry' #进入APP下载页面

  get 'wechat_geometry/geometry'
  get 'lp_login/kol_register'
  post 'lp_login/kol_create'
  post 'lp_login/sms_request'
  get 'lp_login/download'
  get 'leader_login/kol_register'
  post 'leader_login/kol_create'
  post 'leader_login/sms_request'
  get 'leader_login/download'

  # wechat_campaign 新增了点击数
  get 'partner_campaign/campaign',                        to: 'partner_campaign#campaign'
  put 'partner_campaign/:campaign_id/:kol_id/complete',   to: 'partner_campaign#complete'
  resources :partner_campaign

  get 'kol/:id/kol_pk',                                   to: 'kol_pk#index'
  get 'kol_pk/new/vs/:challengee_id',                     to: 'kol_pk#new'
  get 'kol_pk/:challenger_id/vs/:challengee_id/fighting', to: 'kol_pk#fighting'
  get 'kol_pk/:challenger_id/vs/:challengee_id/check',    to: 'kol_pk#check'
  get 'kol_pk/timeout',                                   to: 'kol_pk#timeout'
  get 'kol_pk/:pk_id',                                    to: 'kol_pk#show'

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

  resources :elastic_articles, only: [] do
    member do
      get :forward
    end
  end

  namespace :partners do
    get '/',          to: 'dashboard#index'
    get 'sign_in',    to: 'sessions#new'
    post 'login',     to: 'sessions#create'
    get 'sign_out',   to: 'sessions#destroy'
    resources :dashboard , only: [:index] do
      collection do
        get :income_data
        get :chart1
        get :chart2
        get :chart3
        get :chart4
        get :chart5
        get :chart6
        get :chart7
        get :chart8
      end
    end
    resources :campaigns, only: [:index]
    resources :campaign_invites, only: [:index] do
      get :shows
    end
    resources :kols, only: [:index] do
      member do
        get :activities
        get :shows
        get :capital_flow_sheet
        get :children
      end
    end
  end
end
