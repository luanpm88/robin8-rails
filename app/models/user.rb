class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, #:confirmable,
         :omniauthable, :invitable

  has_many :identities, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :news_rooms, dependent: :destroy
  has_many :releases, dependent: :destroy
  has_many :streams, dependent: :destroy

  has_many :user_products , dependent: :destroy
  has_many :payments ,through: :user_products
  has_many :products,:through => :user_products

  has_many :user_features , dependent: :destroy
  has_many :features,:through => :user_features

  has_many :media_lists, dependent: :destroy
  has_many :pitches
  has_many :pitches_contacts, through: :pitches
  # has_many :user_add_ons, dependent: :destroy
  # has_many :add_ons, through: :user_add_ons

  after_create :create_default_news_room, :decrease_feature_number
  after_destroy :increase_feature_number

  extend FriendlyId
  friendly_id :email, use: :slugged

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

  def current_user_features
    is_primary? ? user_features : invited_by.user_features 
  end

  def is_feature_available?(slug)
    @user = is_primary? ? self : invited_by 
    Feature.joins(:user_features).where("user_features.user_id = '#{@user.id}' AND user_features.available_count > '0' AND features.slug = '#{slug}'").exists?
  end

  def used_count_by_slug(slug)
    case slug
    when 'seat'
      seat_count
    when 'newsroom'
      newsroom_count
    when 'press_release'
      release_count
    when 'smart_release'
      smart_release_count
    when 'media_monitoring'
      stream_count
    when 'personal_media_list'
      media_lists_count
    else
      0
    end
  end

  def available_features
    current_user_features.where("user_features.available_count > '0'")
  end

  def is_primary?
    is_primary != false
  end

  def newsroom_available_count
    current_user_features.newsroom.map(&:available_count).inject{|sum,x| sum + x }
  end

  def newsroom_count
    manageable_users.each.sum{|u| u.news_rooms.count} + news_rooms.count
  end

  def can_create_newsroom
    newsroom_available_count.nil? ? false : newsroom_available_count > 0
  end

  def release_available_count
    current_user_features.press_release.map(&:available_count).inject{|sum,x| sum + x }
  end

  def manageable_users
    User.where(invited_by_id: self.id)
  end

  def release_count
    manageable_users.each.sum{|u| u.releases.count} + releases.count
  end

  def can_create_release
    release_available_count.nil? ? false : release_available_count > 0
  end

  def can_create_stream
    stream_available_count.nil? ? false : stream_available_count > 0
  end

  def stream_available_count
    current_user_features.media_monitoring.map(&:available_count).inject{|sum,x| sum + x }
  end

  def stream_count
    manageable_users.each.sum{|u| u.streams.count} + streams.count
  end

  def can_cancel_add_on?(user_add_on_id)
    add_on = user_products.where(id: user_add_on_id).first.product
    if add_on.slug == "media_moitoring" || add_on.slug == "newsroom" || add_on.slug == "seat" || add_on.slug == "myprgenie_web_distribution"
      return current_user_features.where(product_id: add_on.id).first.available_count > 0 ? true : false
    else
      return false
    end
  end

  def can_create_smart_release
    smart_release_available_count.nil? ? false : smart_release_available_count > 0
  end

  def smart_release_available_count
    current_user_features.smart_release.map(&:available_count).inject{|sum,x| sum + x }
  end

  def smart_release_count
    manageable_users.each.sum{|u| u.pitches.count} + pitches.count
  end

  def can_create_seat
    seat_available_count.nil? ? false : seat_available_count > 0
  end

  def seat_available_count
    current_user_features.seat.map(&:available_count).inject{|sum,x| sum + x }
  end

  def seat_count
    manageable_users.count + 1 # +1 - himself
  end

  def media_lists_count
    lists = current_user_features.personal_media_list
    lists.count == 0 ? 0 : lists.map(&:available_count).inject{|sum,x| sum + x }
  end

  def active_subscription
    @subscriptions = is_primary? ? subscriptions : invited_by.subscriptions
    @active_s ||= @subscriptions.where("((user_products.expiry is NULL OR user_products.expiry >'#{Time.now.utc}') AND user_products.status ='A') OR (user_products.expiry > '#{Time.now.utc}' AND user_products.status = 'C')").last
  end

  def subscriptions
    user_products.joins(:product).where("products.type ='Package'")
  end

  def current_package
    Package.find(subscriptions.last.product_id)
  end

  def current_add_ons
    add_ons_products = user_products.joins(:product).where("products.type ='AddOn'")
    AddOn.where(id: add_ons_products.map(&:product_id)) if add_ons_products.present?
  end

  def recurring_add_ons
    user_products.joins(:product).where("products.type ='AddOn' and (products.interval is NOT NULL OR products.interval >= '30')")
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

  def twitter_post message, identity_id
    twitter_identity = Identity.find(identity_id)
    unless twitter_identity.blank?
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.secrets.twitter[:api_key]
        config.consumer_secret     = Rails.application.secrets.twitter[:api_secret]
        config.access_token        = twitter_identity.token
        config.access_token_secret = twitter_identity.token_secret
      end
      client.update(message)
    end
  end

  def linkedin_post message, identity_id
    linkedin_identity = Identity.find(identity_id)
    unless linkedin_identity.blank?
      data = { comment: message, visibility: {code: 'anyone'} }
      response = HTTParty.post("https://api.linkedin.com/v1/people/~/shares?format=json",
                               headers: { 'Content-Type' => 'application/json'},
                               query: {oauth2_access_token: linkedin_identity.token},
                               body: data.to_json)
      puts response.body, response.code, response.message, response.headers.inspect
    end
  end

  def facebook_post message, identity_id
    facebook_identity = Identity.find(identity_id)
    unless facebook_identity.blank?
      graph = Koala::Facebook::API.new(facebook_identity.token)
      Rails.logger.info graph.inspect
      graph.put_wall_post("I've posted a new Post!", {
                                                       "name" => '',
                                                       "link" => '',
                                                       "description" => message
                                                   })
    end
  end

  def name
    super.present? ? super : "#{first_name} #{last_name}"
  end

  def display_name
    if name.present?
      user_name = name
    elsif first_name.present? && last_name.present?
      user_name = "#{first_name} #{last_name}"
    end
    user_name && email.present? ? "#{user_name}, #{email}" : "#{user_name}#{email}"
  end

  def as_json(options={})
    super(methods: [:active_subscription, :sign_in_count, :recurring_add_ons])
  end
  
  def full_name
    if !first_name.blank? && !last_name.blank?
      "#{first_name} #{last_name}"
    elsif !first_name.blank?
      first_name
    elsif !last_name.blank?
      last_name
    else
      "Robin8"
    end
  end

  def can_export
    user_product = user_products.first
    return false if user_product.blank?
    ["enterprise-monthly", "enterprise-annual", "ultra-monthly", "ultra-annual"].include? user_product.product.slug
  end

  private
    def create_default_news_room
      if is_primary?
        news_room = self.news_rooms.new(
            company_name: "#{self.email}'s Default Newsroom",
            subdomain_name: self.slug,
            default_news_room: true
        )
        news_room.save(validate: false)
      end
    end

    # def needed_user
    #   user.is_primary? ? user : user.invited_by
    # end

    def decrease_feature_number
      if !is_primary
        af = needed_user.user_features.seat.available.joins(:product).where(products: {is_package: false}).first
        uf = af.nil? ? needed_user.user_features.seat.available.first : af
        return false if uf.blank?
        uf.available_count -= 1
        uf.save
      end
    end

    def increase_feature_number
      if !is_primary
        af = needed_user.user_features.seat.available.joins(:product).where(products: {is_package: false}).first
        uf = af.nil? ? needed_user.user_features.seat.available.first : af
        return false if uf.blank?
        uf.available_count += 1
        uf.save
      end
    end
end
