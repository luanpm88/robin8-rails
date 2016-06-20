Rails.application.routes.draw do
  namespace :marketing_dashboard do
    get '/' => 'dashboard#index'
    resources :track_urls
    resources :campaigns, except: [:destroy, :new, :create] do
      collection do
        get 'pending'
        get 'agreed'
      end
      member do
        get :targets
        get :recruit_targets
        post :add_target
        post :add_or_remove_recruit_kol
        delete :delete_target
        get :stop
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
        get 'search'
        post 'search'
      end
      resources :campaign_shows, only: [:index]
      resources :campaigns, only: [:index]
    end
    resources :users, except: [:destroy, :new, :create] do
      match '/recharge' => 'users#recharge' , via: [:post, :get]
      collection do
        get 'search'
        post 'search'
      end
    end
    resources :admin_users, except: [:destroy, :new, :create]
    resources :campaign_invites, except: [:destroy, :new, :create] do
      collection do
        get 'pending'
        get 'passed'
        get 'rejected'
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
        get :campaign_statistics_in_time_range
        get :kol_withdraw_statistics_in_time_range
        post :campaign_statistics_in_time_range
        post :kol_withdraw_statistics_in_time_range
        get :download_kol_amount_statistics
        get :download_campaign_statistics_in_time_range
        get :download_kol_withdraw_statistics_in_time_range
      end
    end
    resources :feedbacks, except: [:destroy, :new, :create]  do
      member  do
        get :processed
      end
    end
    resources :withdraws, except: [:destroy, :new, :create] do
      collection do
        get 'pending'
        get 'agreed'
        get 'rejected'
      end
      match '/agree' => 'withdraws#agree', via: [:post]
      match '/reject' => 'withdraws#reject', via: [:post]
    end
    resources :announcements, except: [:destroy]
    resources :alipay_orders do
      collection do
        post 'search'
      end
    end

    resources :transactions do
      collection do
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

  end
end
