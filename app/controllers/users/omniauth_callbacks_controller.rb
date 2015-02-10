module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def self.provides_callback_for(provider)
      class_eval %Q{
        def #{provider}
          auth = request.env['omniauth.auth']
          if auth.provider == 'twitter' || 'linkedin'
            params = {}
            params[:uid] = auth.uid
            params[:provider] = auth.provider
            params[:token] = auth.credentials.token
            p auth.credentials.secret
            params[:token_secret] = auth.credentials.secret
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

    [:twitter, :linkedin].each do |provider|
      provides_callback_for provider
    end
  end
end