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
  has_many :contacts, through: :media_lists
  has_many :pitches
  has_many :pitches_contacts, through: :pitches

  has_many :campaigns
  has_many :campaign_invites, through: :campaigns

  has_many :article_comments, as: :sender

  has_many :private_kols
  has_many :kols, through: :private_kols
  # has_many :user_add_ons, dependent: :destroy
  # has_many :add_ons, through: :user_add_ons

  after_create :create_default_news_room, :decrease_feature_number
  after_destroy :increase_feature_number

  include Models::Identities

  class EmailValidator < ActiveModel::Validator
    def validate(record)
      if record.new_record? and Kol.exists?(:email=>record.email)
        record.errors[:email] << "Email has already been taken"
      end
    end
  end

  def invited_users_list
    current_users=User.where(invited_by_id: needed_user.id)
    invited_id=""
    current_users.all.each do |current_user|
      invited_id << current_user.id.to_s << ", "
    end
    return invited_id << needed_user.id.to_s
  end

  def current_user_features
    is_primary? ? user_features : invited_by.user_features
  end

  def is_feature_available?(slug)
    users_id = invited_users_list
    Feature.joins(:user_features).unscope(where: :user_id).where("user_features.user_id IN (#{users_id}) AND user_features.available_count > '0' AND features.slug = '#{slug}'").exists?
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
    users_id = invited_users_list
    user_features.unscope(where: :user_id).where("user_id IN (#{users_id})").where("user_features.available_count > '0'")
  end

  def is_primary?
    is_primary != false
  end


  def newsroom_available_count
    users_id = invited_users_list
    user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").newsroom.map(&:available_count).inject{|sum,x| sum + x }
  end

  def newsroom_count
    manageable_users.each.sum{|u| u.news_rooms.count} + news_rooms.count
  end

  def can_create_newsroom
    newsroom_available_count.nil? ? false : newsroom_available_count > 0
  end

########################################################################################################
  def myprgenie_available_count
    users_id = invited_users_list
    user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").myprgenie_web_distribution.map(&:available_count).inject{|sum,x| sum + x }
  end

  def can_create_myprgenie
    myprgenie_available_count.nil? ? false : myprgenie_available_count >= 1
  end


  def accesswire_available_count
    users_id = invited_users_list
    user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").accesswire_distribution.map(&:available_count).inject{|sum,x| sum + x }
  end

  def can_create_accesswire
    accesswire_available_count.nil? ? false : accesswire_available_count >= 1
  end


  def prnewswire_available_count
    users_id = invited_users_list
    user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").pr_newswire_distribution.map(&:available_count).inject{|sum,x| sum + x }
  end

  def can_create_prnewswire
    prnewswire_available_count.nil? ? false : prnewswire_available_count >= 1
  end
##########################################################################################################

  def release_available_count
    users_id = invited_users_list
    user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").press_release.map(&:available_count).inject{|sum,x| sum + x }
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
    users_id = invited_users_list
    user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").media_monitoring.map(&:available_count).inject{|sum,x| sum + x }
  end

  def media_list_available_count
    users_id = invited_users_list
    user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").personal_media_list.map(&:available_count).inject{|sum,x| sum + x }
  end

  def can_create_media_list
    media_list_available_count.nil? ? false : media_list_available_count > 0
  end

  def stream_count
    manageable_users.each.sum{|u| u.streams.count} + streams.count
  end

  def can_cancel_add_on?(user_add_on_id)
    users_id = invited_users_list
    add_on = user_products.unscope(where: :user_id).where("user_id IN (#{users_id})").where(id: user_add_on_id).first.product
    if add_on.slug == "media_monitoring" || add_on.slug == "newsroom" || add_on.slug == "seat" || add_on.slug == "myprgenie_web_distribution" || add_on.slug == "pr_newswire_distribution" || "accesswire_distribution"
      return user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").where(product_id: add_on.id).first.available_count > 0 ? true : false
    else
      return false
    end
  end

  def can_create_smart_release
    smart_release_available_count.nil? ? false : smart_release_available_count > 0
  end

  def smart_release_available_count
    users_id = invited_users_list
    user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").smart_release.map(&:available_count).inject{|sum,x| sum + x }
  end

  def smart_release_count
    manageable_users.each.sum{|u| u.pitches.count} + pitches.count
  end

  def can_create_seat
    seat_available_count.nil? ? false : seat_available_count > 0
  end

  def seat_available_count
    users_id = invited_users_list
    user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").seat.map(&:available_count).inject{|sum,x| sum + x }
  end

  def seat_count
    manageable_users.count + 1 # +1 - himself
  end

  # def can_create_seat
  #   seat_available_count.nil? ? false : seat_available_count > 1
  # end

  # def seat_available_count
  #   current_user_features.seat.map(&:available_count).inject{|sum,x| sum + x }
  # end

  # def seat_count
  #   manageable_users.count + 1 # +1 - himself
  # end

  def media_lists_count
    users_id = invited_users_list
    lists = user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").personal_media_list
    lists.count == 0 ? 0 : lists.map(&:available_count).inject{|sum,x| sum + x }
  end

  def active_subscription
    @subscriptions = is_primary? ? subscriptions : invited_by.subscriptions
    @active_s ||= @subscriptions.where("((user_products.expiry is NULL OR user_products.expiry >'#{Time.now.utc}') AND user_products.status ='A')").last
  end

  def subscriptions
    user_products.joins(:product).where("products.type ='Package'")
  end

  def current_package
    Package.find(subscriptions.last.product_id)
  end

  def current_add_ons
    users_id = invited_users_list
    add_ons_products = user_products.joins(:product).unscope(where: :user_id).where("user_products.user_id IN (#{users_id})").where("products.type ='AddOn'")
    AddOn.where(id: add_ons_products.map(&:product_id)) if add_ons_products.present?
  end
  
  def current_active_add_ons
    add_ons_products = current_user.user_products.joins(:product).where("products.type ='AddOn'")
    if add_ons_products.present?
      user_addons_features = needed_user.user_features.where.not(available_count: 0).where(product_id: add_ons_products.map(&:product_id))
      add_ons_products.where(product_id: user_addons_features.map(&:product_id))
    else
      []
    end
  end

  def recurring_add_ons
    users_id = invited_users_list
    user_products.joins(:product).unscope(where: :user_id).where("user_products.user_id IN (#{users_id})").where("products.type ='AddOn' and (products.interval is NOT NULL OR products.interval >= '30')")
  end
  


  def twitter_post(message, identity_id=nil)
    identity = identity_id.nil? ? twitter_identity : Identity.find(identity_id)

    unless identity.blank?
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = Rails.application.secrets.twitter[:api_key]
        config.consumer_secret     = Rails.application.secrets.twitter[:api_secret]
        config.access_token        = identity.token
        config.access_token_secret = identity.token_secret
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

  def weibo_post message, identity_id
    weibo_identity = Identity.find(identity_id)
    unless weibo_identity.blank?
      response = HTTParty.post("https://api.weibo.com/2/statuses/update.json",
                               query: {access_token: weibo_identity.token},
                               body: { status: message })
    end
  end

  def facebook_post message, identity_id
    facebook_identity = Identity.find(identity_id)
    unless facebook_identity.blank?
      graph = Koala::Facebook::API.new(facebook_identity.token)
      Rails.logger.info graph.inspect
      graph.put_wall_post(message,
                          {"appsecret_proof" => OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"),
                                                                        Rails.application.secrets.facebook[:app_secret],
                                                                        facebook_identity.token),
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
    super(methods: [:active_subscription, :sign_in_count, :recurring_add_ons, :current_active_add_ons])
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

    def needed_user
      is_primary? ? self : self.invited_by
    end

    def decrease_feature_number
      af = needed_user.user_features.seat.available.joins(:product).where(products: {is_package: false}).first
      uf = af.nil? ? needed_user.user_features.seat.available.used.first : af
      return false if uf.blank?
      uf.available_count -= 1
      uf.save
    end

    def increase_feature_number
      af = needed_user.user_features.seat.available.joins(:product).where(products: {is_package: false}).first
      uf = af.nil? ? needed_user.user_features.seat.first : af
      return false if uf.blank?
      uf.available_count += 1
      uf.save
    end
end

