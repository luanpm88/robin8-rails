Rails.application.routes.draw do
  namespace :marketing_dashboard do
    get 'invite_code' => 'invite_code#index'
    get '/' => 'dashboard#index'
    get 'edit_password' => 'dashboard#edit_password'
    patch 'update_password' => 'dashboard#update_password'


    resources :creations do
      member do 
        get :auditing
        put :update_auditing

        get :tenders
      end
      collection do
        get :search_kols
      end
    end

    resources :creation_selected_kols, only: [:index]

    resources :tags, only: [:index, :new, :create] do 
      match '/add_circle' => 'tags#add_circle', via: [:post, :get]
    end

    resources :circles, only: [:index, :new, :create] do 
      match '/add_tag' => 'circles#add_tag', via: [:post, :get]
    end

    resources :terraces

    resources :creators
    resources :weibo_accounts
    resources :public_wechat_accounts
    
    resources :article_contents do
      member do
        get :sync
      end
    end
    resources :cps_materials do
      member do
        get :switch_enable
        get :switch_hot
      end
    end
    resources :cps_articles do
      member do
        get :materials
        get :promotion_orders
        get :article_shares
        get :switch
        get :check
      end
      collection do
        get :need_shield
      end
    end
    resources :cps_promotion_orders do
      collection do
        get :items
      end
    end
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
        put :reject
        post :batch_add_or_remove_recruit_kol
      end
      member do
        get :targets
        get :add_example_screenshot
        get :add_applying_description
        get :recruit_targets
        post :add_target
        post :add_or_remove_recruit_kol
        delete :delete_target
        get :stop
        get :push_all
        post :refresh_budget
        post :save_example_screenshot_and_remark
        patch :save_applying_description
        match 'add_seller', via: [:post, :get]
        get :push_record
        match :set_auth_type, via: [:put, :get]

        put :lift_kol_level_count
        put :push_to_partners
        put :settle_for_partners
        get :azb_csv
        put :terminate_ali_campaign
        get :bots
        put :update_bots
        put :perfect
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
      match '/add_admintag' => 'kols#add_admintag', via: [:post, :get]
      match '/remove_admintag' => 'kols#remove_admintag', via: [:post]

      collection do
        get 'banned'
        get 'from_mcn'
        get 'from_app'
        get 'applying'
        get 'passed'
        get 'rejected'
        get 'hot_kols'
      end
      member do
        match 'campaign_compensation', via: [:post, :get]
        get :transaction
        get :edit_profile
        put :update_profile
        get :invites
      end
      resources :feedbacks
      resources :campaign_shows, only: [:index]
      resources :campaigns, only: [:index]
    end


    resources :voter_ships, only: [:index]

    resources :users, except: [:destroy, :new, :create] do
      match '/recharge' => 'users#recharge' , via: [:post, :get]
      match '/withdraw' => 'users#withdraw' , via: [:post, :get]
      member do
        put 'live'
        put 'active'
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
        post :bind_e_wallet
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
        get :registered_invitations
        get :campaign_release_count
        get :cooperation_data_reportes
        post :cooperation_data_reportes
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
      match '/confiscate' => 'withdraws#confiscate', via: [:post]
      match '/permanent_frozen' => 'withdraws#permanent_frozen', via: [:post]
      match '/permanent_frozen_alipay' => 'withdraws#permanent_frozen_alipay', via: [:post]
    end
    resources :announcements
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

    resources :invite_codes, except: [:destroy] do
      member do
        patch :update
      end
    end
    resources :talking_data
    resources :kol_data
    resources :campaign_data

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

    resources :elastic_articles, only: [:index] do
      collection do
        get :kols
        get :kols_red_money
      end
    end

    namespace :e_wallets do
      resources 'promotions' do
        member do
          put :modify_state
        end
      end

      resources 'kol_promotions' do
        member do
          put :modify_state
        end
      end

      resources 'campaigns', only:[:index] do
        resources 'transactions', only:[:index] do
          collection do
            post :update_txid
          end
        end
      end

      resources :bills, only: [:index]

      resources :redis_sets, only: [] do
        collection do
          get :sales
          put :update_sales
        end
      end

      resources :kols, only: [:index] do
        resources 'transactions', only:[] do 
        end
        member do
          get :transactions
        end
      end

    end



    namespace :utilities do
      resource  "verify_code"
      resource  "marketing_message"
      resources "sms_messages"
      resources "open_tokens"
      resources "settings" do
        collection do
          post "update_value"
        end
      end
      resources :promotions do
        member do
          put :invalid
        end
      end
      resources :redis_extends, only: [] do
        collection do
          get :ios_detail
          get :invite_switch
          get :vest_bag_detail
          get :vote_switch
          put :update_redis_value
          match 'reg_code', via: [:post, :get]
          get :get_reg_code
        end
      end
      resources :admintag_strategies
    end
  end
end
