module Models::Oauth

  def find_for_oauth(auth, signed_in_resource = nil)
    identity = Identity.find_for_oauth(auth)

    user = signed_in_resource ? signed_in_resource : identity.user

    if user.nil?
      email = auth[:email]
      user = User.where(:email => email).first if email

      if user.nil?
        raise "No sign ups"
      end
    end
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

end
