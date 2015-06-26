module Identities
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

  def weibo_identity
    identities.where(provider: 'weibo').first
  end

  def wechat_identity
    identities.where(provider: 'wechat').first
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

  def weibo_identities
    identities.where(provider: 'weibo')
  end

  def wechat_identities
    identities.where(provider: 'wechat')
  end

  def all_identities
    identities_by_providers = {}
    identities_by_providers[:twitter] = twitter_identities
    identities_by_providers[:facebook] = facebook_identities
    identities_by_providers[:google] = google_identities
    identities_by_providers[:linkedin] = linkedin_identities
    identities_by_providers[:weibo] = weibo_identities
    identities_by_providers[:wechat] = wechat_identities
    identities_by_providers
  end
end
