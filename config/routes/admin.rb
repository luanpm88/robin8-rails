Rails.application.routes.draw do
  namespace :marketing_dashboard do
    get '/' => 'dashboard#index'
    get 'edit_password' => 'dashboard#edit_password'
    patch 'update_password' => 'dashboard#update_password'
    resources :cps_materials do

    end
    resources :cps_articles do
      member do
        get :materials
        get :promotion_orders
        get :article_shares
      end
    end
    resources :cps_promotion_orders
    resources :cps_promotion_orders

    resources :track_urls
    resources :hot_items
    resources :helper_docs
    resources :helper_tags
    resources :social_accounts do
      collection do
        get :cities
      end
    end

    resources :kol_shows

    resources :campaigns, except: [:destroy, :new, :create] do
      collection do
        get 'pending'
        get 'asking'
        get 'agreed'
        get 'rejected'
        get 'testable'
      end
      member do
        get :targets
        get :add_example_screenshot
        get :recruit_targets
        post :add_target
        post :add_or_remove_recruit_kol
        delete :delete_target
        get :stop
        get :push_all
        post :refresh_budget
        patch :save_example_screenshot_and_remark
        match 'add_seller', via: [:post, :get]
      end
      collection do
        put :reject
      end

      match '/agree' => 'campaigns#agree', via: [:put]
      resources :kols, only: [:index]
      resources :campaign_shows, only: [:index]
      resources :campaign_invites, only: [:index]
    end
    resources :kols, except: [:destroy, :new, :create] do
      match '/ban' => 'kols#ban', via: [:post, :get]
      match '/disban' => 'kols#disban', via: [:post]
      match '/withdraw' => 'kols#withdraw' , via: [:post, :get]

      collection do
        get 'banned'
        get 'hot'
        get 'from_mcn'
        get 'from_app'
        get 'applying'
        get 'passed'
        get 'rejected'
      end
      member do
        match 'campaign_compensation', via: [:post, :get]
        get :transaction
        get :edit_profile
        put :update_profile
      end
      resources :feedbacks
      resources :campaign_shows, only: [:index]
      resources :campaigns, only: [:index]
    end
    resources :users, except: [:destroy, :new, :create] do
      match '/recharge' => 'users#recharge' , via: [:post, :get]
      member do
        put 'live'
      end
      collection do
        get 'search'
        post 'search'
      end
    end

    resources :admin_users do
      member  do
        get :edit_auth
        patch :update_auth
      end
    end

    resources :campaign_invites, except: [:destroy, :new, :create] do
      collection do
        get 'pending'
        get 'passed'
        get 'rejected'
        post 'change_multi_img_status'
      end
      match '/pass' => 'campaign_invites#pass', via: [:post]
      match '/reject' => 'campaign_invites#reject', via: [:post, :get]
      resources :campaign_shows, only: [:index]
    end
    resources :stastic_datas do
      collection do
        get :from_source
        get :new_kol
        get :day_statistics
        get :kol_amount_statistics
        get :user_recharge_statistics
        get :campaign_statistics_in_time_range
        get :kol_withdraw_statistics_in_time_range
        post :campaign_statistics_in_time_range
        post :kol_withdraw_statistics_in_time_range
        get :download_kol_amount_statistics
        get :download_user_recharge_statistics
        get :download_campaign_statistics_in_time_range
        get :download_kol_withdraw_statistics_in_time_range
      end
    end
    resources :feedbacks, except: [:destroy, :new, :create]  do
      collection do
        post :reply
      end
      member  do
        get :processed
      end
    end
    resources :withdraws, except: [:destroy, :new, :create] do
      collection do
        get 'pending'
        get 'checked'
        get 'agreed'
        get 'rejected'
        get 'permanent_prohibited'
        post 'search'
        match 'batch_handle', via: [:post]
      end
      match '/check' => 'withdraws#check', via: [:post]
      match '/agree' => 'withdraws#agree', via: [:post]
      match '/reject' => 'withdraws#reject', via: [:post]
      match '/permanent_frozen' => 'withdraws#permanent_frozen', via: [:post]
      match '/permanent_frozen_alipay' => 'withdraws#permanent_frozen_alipay', via: [:post]
    end
    resources :announcements, except: [:destroy]
    resources :kol_announcements do
      member do
        get :switch
      end
    end
    resources :app_upgrades do
      member do
        get :switch
      end
    end
    resources :alipay_orders do
      collection do
        get "from_pc"
        get "from_app"
        get "campaigns"
        post "search_campaigns"
        put "change_campaign_desc"
      end
      member do
        match 'add_seller', via: [:post, :get]
      end
    end

    resources :manual_recharges, only:[:index] do
      collection do
        post 'search'
      end
      member do
        match 'add_seller', via: [:post, :get]
      end
    end

    resources :transactions do
      collection do
        get 'discount'
        get 'search'
      end
    end

    resources :invoice_histories do
      collection do
        get 'search'
      end
      member do
        get 'send'
        match 'send_express' => 'invoice_histories#send_express', via: [:post]
      end
    end

    resources :lottery_products do
      member do
        patch :pub
      end
    end

    resources :lottery_activities
    resources :lottery_expresses

    resources :alipay_account_blacklists do
      member do
        get :disban
      end
    end

    resources :verify_codes do
      collection do
        post 'get_verify_code'
      end
    end
  end
end
