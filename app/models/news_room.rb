class NewsRoom < ActiveRecord::Base
  VALID_TYPES = ['Government Agency', 'Non-Profit', 'Privately Held', 'Public Company', 'LLC', 'Educational Institution']
  VALID_SIZES = ['Myself Only', '1-5 employees', '6-10 employees', '11-50 employees', '51-200 employees',
                  '201-500 employees', '501-1000 employees', '1001-5000 employees', '5001-10,000 employees', '10,001 or more employees'
                ]

  default_scope { where(parent_id: nil) }

  belongs_to :user
  has_and_belongs_to_many :industries
  has_many :releases, dependent: :destroy
  has_many :attachments, as: :imageable, dependent: :destroy
  has_many :followers, dependent: :destroy
  has_one :preview_news_room, foreign_key: :parent_id, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true
  before_create :set_campaign_name
  after_create :decrease_feature_number
  after_destroy :increase_feature_numner

  validates :company_name, presence: true
  validates :user_id, presence: true
  validates :subdomain_name, presence: true, uniqueness: true
  # validates :campaign_name, uniqueness: true
  validates_inclusion_of :room_type, in: VALID_TYPES, allow_blank: true
  validates_inclusion_of :size, in: VALID_SIZES, allow_blank: true
  validate :twitter_account_exists

  def city_state
    str = [city, state]
    str.reject! { |c| c.blank? }
    str.join(', ')
  end

  def location
    str = [address_1, postal_code, city, state, country]
    str.reject! { |c| c.blank? }
    str.join(', ')
  end

  def has_contact_info?
    [address_1, postal_code, city, state, country, web_address, email].reject(&:blank?).length > 0
  end

  def has_social_links?
    [facebook_link, twitter_link, linkedin_link, instagram_link].reject(&:blank?).length > 0
  end

  private

    def twitter_account_exists
      unless twitter_link.blank?
        twitter_name = twitter_link.split('/').last
        client = Twitter::REST::Client.new do |config|
          config.consumer_key        = Rails.application.secrets.twitter[:api_key]
          config.consumer_secret     = Rails.application.secrets.twitter[:api_secret]
        end
        begin
          response = client.user(twitter_name)
        rescue Twitter::Error => e
          errors.add(:twitter_link, e.message)
        rescue Exception
          errors.add(:twitter_link, "sorry, something has went wrong")
        end
      end
    end

    def set_campaign_name
      self.campaign_name = self.company_name
    end

    def decrease_feature_number
      uf = user.user_features.newsroom.available.first
      return false if uf.blank?
      uf.available_count -= 1
      uf.save
    end

    def increase_feature_numner
      uf = user.user_features.newsroom.not_available.first
      return false if uf.blank?
      uf.available_count += 1
      uf.save
    end
    
end
