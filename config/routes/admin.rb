Rails.application.routes.draw do
  namespace :marketing_dashboard do
    get '/' => 'dashboard#index'
    resources :campaigns, except: [:destroy, :new, :create] do
      collection do
        get 'pending'
        get 'agreed'
      end
      member do
        get :targets
        post :add_target
        delete :delete_target
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
        get :day_statics
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
  end
end
