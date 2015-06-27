module Models::Oauth

  def find_for_oauth(auth, signed_in_resource = nil)
    identity = Identity.find_for_oauth(auth)

    resource = signed_in_resource ? signed_in_resource : identity.user

    if resource.nil?
      email = auth[:email]
      resource = self.where(:email => email).first if email

      if resource.nil?
        resource = self.new(
            name: auth[:name],
            email: email,
            password: Devise.friendly_token[0,20],
            confirmed_at: DateTime.now
        )
        resource.save!
      end
    end
    if self == User
      if identity.user != resource
        identity.user = resource
        identity.save!
      end
    else
      if identity.kol != resource
        identity.kol = resource
        identity.save!
      end
    end
    resource
  end

end

