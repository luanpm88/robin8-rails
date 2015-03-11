class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :omniauthable, :invitable

  has_many :identities, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :news_rooms, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :streams, dependent: :destroy
  has_many :payments,through: :subscriptions
  has_many :subscriptions , dependent: :destroy
  has_many :media_lists, dependent: :destroy
  has_many :pitches
  has_many :pitches_contacts, through: :pitches

  after_create :create_default_news_room

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

  def active_subscription
    @active_s ||= subscriptions.where("user_id ='#{self.id}' AND (expiry is NULL OR expiry >'#{Time.now.utc}') AND status ='A'").last
  end

  def twitter_identity
    identities.where(provider: 'twitter').first
  end

  def linkedin_identity
    identities.where(provider: 'linkedin').first
  end

  def facebook_identity
    identities.where(provider: 'facebook').first
  end

  def twitter_post message
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter[:api_key]
      config.consumer_secret     = Rails.application.secrets.twitter[:api_secret]
      config.access_token        = twitter_identity.token
      config.access_token_secret = twitter_identity.token_secret
    end
    client.update(message)
  end

  def linkedin_post message #need check
    data = { comment: message, visibility: {code: 'anyone'} }
    response = HTTParty.post("https://api.linkedin.com/v1/people/~/shares?format=json",
                             headers: { 'Content-Type' => 'application/json'},
                             query: {oauth2_access_token: linkedin_identity.token},
                             body: data.to_json)
    puts response.body, response.code, response.message, response.headers.inspect
  end

  def name
    super.present? ? super : "#{first_name} #{last_name}"
  end

  def facebook_post message
    graph = Koala::Facebook::API.new(facebook_identity.token)
    Rails.logger.info graph.inspect
    graph.put_wall_post("I've posted a new Post!", {
                                                     "name" => '',
                                                     "link" => '',
                                                     "description" => message
                                                 })
  end

  def as_json(options={})
    super(methods: [:active_subscription, :sign_in_count])
  end

  private
  def create_default_news_room
    self.news_rooms.create(
        company_name: "#{self.email}'s Default Newsroom",
        subdomain_name: "#{self.email}'s Default Subdomain",
        default_news_room: true
    )
  end
end
