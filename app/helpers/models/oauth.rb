module Models::Oauth

  def find_for_oauth(auth, signed_in_resource = nil)
    identity = Identity.find_for_oauth(auth)

    resource = signed_in_resource ? signed_in_resource : identity.user || identity.kol

    if resource.nil?
      email = auth[:email]
      resource = (self.where(:email => email).first if email) || (Kol.where(:email => email).first if email)
      opts = {
        email: email,
        password: Devise.friendly_token[0,20],
        confirmed_at: DateTime.now
      }
      if self.attribute_names.include? "name"
        opts[:name] = auth[:name]
      else
        opts[:first_name] = auth[:name]
      end
      if resource.nil?
        resource = self.new opts
        resource.save!
      end
    end
    if resource.class == User
      if identity.user != resource
        identity.user = resource
        identity.kol_id = nil
        identity.save!
      end
    else
      if identity.kol != resource
        identity.kol = resource
        identity.user_id = nil
        identity.save!

        # TODO this appear in multi place, should placed one place
        # tell data engine a new uid inserted via api
        kol_auth_info = { provider: auth.provider, uid: auth.uid }
        IntegrationWithDataEngineWorker.perform_async 'insert_kol', kol_auth_info
      end
    end
    resource
  end

end

