module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def self.provides_callback_for(provider)
      class_eval %Q{
        def #{provider}
          auth = request.env['omniauth.auth']
          
          params = {}
          params[:uid] = auth.uid
          params[:provider] = auth.provider
          params[:token] = auth.credentials.token
          params[:token_secret] = auth.credentials.secret
          params[:name] = auth.provider == 'twitter' ? auth.info.nickname : auth.info.name
          params[:email] = auth.info.email

          params[:url] = case auth.provider
          when 'facebook'
            auth.extra.raw_info.link
          when 'google_oauth2'
            auth.extra.raw_info.profile
          when 'twitter'
            auth.info.urls[:Twitter]
          when 'linkedin'
            auth.info.urls.public_profile
          end

          if current_user.nil?
            @user = User.find_for_oauth(params)
            if @user.persisted?
              sign_in @user
            end
          else
            @identity = Identity.find_for_oauth(params)
            if @identity.user != current_user
              @identity.user = current_user
              @identity.save
            end
          end
          render 'twitter_popup_close', :layout => false          
        end
      }
    end

    def failure
      p params
      render 'twitter_popup_close', :layout => false
    end

    [:twitter, :linkedin, :facebook, :google_oauth2].each do |provider|
      provides_callback_for provider
    end
  end
end