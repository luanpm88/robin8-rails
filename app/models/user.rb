class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable

  has_many :identities, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :news_rooms, dependent: :destroy

  def self.find_for_oauth(auth, signed_in_resource = nil)
    identity = Identity.find_for_oauth(auth)

    user = signed_in_resource ? signed_in_resource : identity.user

    if user.nil?
      email = auth[:email]
      user = User.where(:email => email).first if email

      if user.nil?
        user = User.new(
          name: auth[:name],
          email: email,
          password: Devise.friendly_token[0,20],
          confirmed_at: DateTime.now
        )
        user.save!
      end
    end
    if identity.user != user
      identity.user = user
      identity.save!
    end
    user
  end

  def twitter_identity
    identities.where(provider: 'twitter').first
  end

  def linkedin_identity
    identities.where(provider: 'linkedin').first
  end

  def twitter_post message
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = TWITTER_API_KEY
      config.consumer_secret     = TWITTER_API_SECRET
      config.access_token        = twitter_identity.token
      config.access_token_secret = twitter_identity.token_secret
    end  
    client.update(message)
  end

  def linkedin_post message #need check
    data = { comment: message, visibility: {code: 'anyone'} }

    p linkedin_identity.token

    response = HTTParty.post("https://api.linkedin.com/v1/people/~/shares?format=json", 
              headers: { 'Content-Type' => 'application/json'}, 
              query: {oauth2_access_token: linkedin_identity.token}, 
              body: data.to_json)
    puts response.body, response.code, response.message, response.headers.inspect
  end
end
