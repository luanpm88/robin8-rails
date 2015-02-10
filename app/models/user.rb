class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, :omniauthable

  has_many :identities, dependent: :destroy
  has_many :posts, dependent: :destroy

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
      config.consumer_key        = 'chfbNFBkf56gJT2BDzmCNNfgv'
      config.consumer_secret     = 'WJvtq91oZgvGIJQl33J8kprn4eeWRlCzj4qlYulAyzwuxKATS3'
      config.access_token        = twitter_identity.token
      config.access_token_secret = twitter_identity.token_secret
    end  
    client.update(message)
  end

  def linkedin_post message #need check
    client = LinkedIn::Client.new('77pzzhbbrahh62', 'h9xZrB8SnYrx03KZ') 
    client.authorize_from_access(linkedin_identity.token, linkedin_identity.token_secret)

    client.add_share(:comment => message)
  end
end
