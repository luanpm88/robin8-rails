require 'google/api_client'

class ServiceAccount
  attr_reader :access_token, :user, :first_profile
  def service_account_user(scope="https://www.googleapis.com/auth/analytics.readonly")
    client = Google::APIClient.new(
      :application_name => "Some application name",
      :application_version => "1.0"
    )
    key = Google::APIClient::PKCS12.load_key("robin8-key.p12", "notasecret")
    service_account = Google::APIClient::JWTAsserter.new("800182934383-g1ubtr8flrfda4virvk07sh73v1t5c9u@developer.gserviceaccount.com", scope, key)
    client.authorization = service_account.authorize
    oauth_client = OAuth2::Client.new("", "", {
      :authorize_url => 'https://accounts.google.com/o/oauth2/auth',
      :token_url => 'https://accounts.google.com/o/oauth2/token'
    })
    token = OAuth2::AccessToken.new(oauth_client, client.authorization.access_token, expires_in: 1.hour)
    user = Legato::User.new(token)
    @access_token = token
    @user = user
    @first_profile = user.profiles.first

    # after an hour or so
    user.access_token.expired?
  end
end