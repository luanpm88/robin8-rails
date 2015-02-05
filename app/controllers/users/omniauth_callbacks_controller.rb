module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def self.provides_callback_for(provider)
      class_eval %Q{
        def #{provider}
          auth = request.env['omniauth.auth']
          if auth.provider == 'twitter'
            params = {}
            params[:uid] = auth.uid
            params[:provider] = 'twitter'
            params[:token] = auth.credentials.token
            params[:name] = auth.info.name

            @identity = Identity.find_for_oauth(params)
            if @identity.user != current_user
              @identity.user = current_user
              @identity.save
            end
          end
          
          return render 'twitter_popup_close', :layout => false
        end
      }
    end

    [:twitter].each do |provider|
      provides_callback_for provider
    end
  end
end