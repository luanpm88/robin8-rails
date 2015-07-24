module Models::Identities
  def twitter_identity
    identities.where(provider: 'twitter').first
  end

  def linkedin_identity
    identities.where(provider: 'linkedin').first
  end

  def facebook_identity
    identities.where(provider: 'facebook').first
  end

  def google_identity
    identities.where(provider: 'google_oauth2').first
  end

  def twitter_identities
    identities.where(provider: 'twitter')
  end

  def linkedin_identities
    identities.where(provider: 'linkedin')
  end

  def facebook_identities
    identities.where(provider: 'facebook')
  end

  def google_identities
    identities.where(provider: 'google_oauth2')
  end

  def all_identities
    identities_by_providers = {}
    identities_by_providers[:twitter] = twitter_identities
    identities_by_providers[:facebook] = facebook_identities
    identities_by_providers[:google] = google_identities
    identities_by_providers[:linkedin] = linkedin_identities
    identities_by_providers
  end
end
