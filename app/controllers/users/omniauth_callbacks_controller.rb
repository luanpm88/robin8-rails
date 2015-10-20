module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # TODO: perhaps we should get rid of this code generation, it's useless
    # here
    def self.provides_callback_for(provider)
      class_eval %Q{
        def #{provider}
          auth = request.env['omniauth.auth']

          if Rails.env.development?
            puts "Got following auth info:"
            puts auth.to_yaml
          end

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
          when 'weibo'
            auth.info.urls[:Weibo]
          end

          if current_user.nil? and current_kol.nil?
            someone = User
            if cookies[:kol_social] == "yeah"
              someone = Kol
              cookies[:kol_social] = "no"
            end
            @someone = someone.find_for_oauth(params)
            if @someone.persisted?
              cookies[:kol_signin] = "no"
              sign_in @someone
              if @someone.class == Kol
                cookies[:kol_signin] = "yeah"
              end
            end
          else
            @identity = Identity.find_for_oauth(params)
            if current_kol.nil?
              if @identity.user != current_user
                @identity.user = current_user
                @identity.kol_id = nil
                @identity.save
              end
            else
              if @identity.kol != current_kol
                @identity.kol = current_kol
                @identity.user_id = nil
                @identity.save

                # tell data engine a new uid inserted via api
                kol_auth_info = { provider: auth.provider, uid: auth.uid }
                IntegrationWithDataEngineWorker.perform_async 'insert_kol', kol_auth_info
              end
            end
          end
          if request.env['omniauth.params']['provider'].nil?
            render 'twitter_popup_close', :layout => false
          else
            redirect_to root_path
          end
        end
      }
    end

    def failure
      p params
      render 'twitter_popup_close', :layout => false
    end

    [:twitter, :linkedin, :facebook, :google_oauth2, :weibo, :wechat].each do |provider|
      provides_callback_for provider
    end
  end
end
