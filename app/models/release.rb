class Release < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user
  belongs_to :news_room, counter_cache: true
  has_many :pitches
  has_many :draft_pitches

  validates :user_id, presence: true
  validates :title, presence: true
  validate :can_be_created, on: :create

  has_many :attachments, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true

  scope :by_news_room, ->(id) {where(news_room_id: id)}
  scope :published, -> { where(is_private: false) }
  
  before_save :pos_tagger, :entities_counter, :set_published_at
  after_create :decrease_feature_number

  after_destroy :increase_feature_number
  after_save :update_images_links
  
  def plain_text
    coder = HTMLEntities.new
    coder.decode ActionController::Base.helpers.strip_tags(text)
  end

  def should_generate_new_friendly_id?
    slug.blank? || title_changed?
  end
  
  def permalink
    host = Rails.application.secrets[:host]
    subdomain_name = self.news_room.subdomain_name
    
    "http://#{subdomain_name}.#{host}/releases/#{slug}"
  end

  def images
    attachments.where(attachment_type: 'image')
  end

  def videos
    attachments.where(attachment_type: 'video')
  end

  def files
    attachments.where(attachment_type: 'file')
  end
  
  private

  def update_images_links
    urls = self.text.scan(/(?:https?:\/\/)?(?:www\.)?ucarecdn.com\/.*?\//)
    if urls.count > 0
      AmazonStorageRelease.perform_async(self.id)
    end
  end

  def can_be_created
    errors.add(:user, "you've reached the max numbers of releases.") if user && !user.can_create_release
  end

  def set_published_at
    self.published_at = Time.now.utc if self.published_at.blank?
  end
  
  def pos_tagger
    if Rails.application.secrets[:pos_tagger_api]
      response = HTTParty.post(Rails.application.secrets[:pos_tagger_api][:url], 
        body: {text: plain_text}).parsed_response
      
      self.characters_count = response["characters_count"]
      self.words_count = response["words_count"]
      self.sentences_count = response["sentences_count"]
      self.paragraphs_count = response["paragraphs_count"]
      self.nouns_count = response["nouns_count"]
      self.adjectives_count = response["adjectives_count"]
      self.adverbs_count = response["adverbs_count"]
    end
  end
  
  def entities_counter
    client = AylienTextApi::Client.new
    
    response = client.entities! text: plain_text
    
    self.organizations_count = (response[:entities][:organization] || []).size
    self.places_count = (response[:entities][:location] || []).size
    self.people_count = (response[:entities][:person] || []).size
  end

  def needed_user
    user.is_primary? ? user : user.invited_by
  end

  def decrease_feature_number
    af = needed_user.user_features.press_release.available.joins(:product).where(products: {is_package: false}).first
    uf = af.nil? ? needed_user.user_features.press_release.available.first : af
    return false if uf.blank?
    uf.available_count -= 1
    uf.save
  end


  def increase_feature_number
    af = needed_user.user_features.press_release.used.joins(:product).where(products: {is_package: false}).first
    uf = af.nil? ? needed_user.user_features.press_release.used.first : af
    return false if uf.blank?
    uf.available_count += 1
    uf.save
  end

  def decrease_newswire_myprgenie
    uf = needed_user.user_features.myprgenie_web_distribution.available.first
    return false if uf.blank?
    uf.available_count -= 1
    uf.save
  end

  def decrease_newswire_accesswire
    uf = needed_user.user_features.accesswire_distribution.available.first
    return false if uf.blank?
    uf.available_count -= 1
    uf.save
  end

  def decrease_newswire_prnewswire
    uf = needed_user.user_features.pr_newswire_distribution.available.first
    return false if uf.blank?
    uf.available_count -= 1
    uf.save
  end

  def decrease_newswire_features
    myprgenie_ = myprgenie_changed? && myprgenie
    accesswire_ = accesswire_changed? && accesswire
    prnewswire_ = prnewswire_changed? && prnewswire

    decrease_newswire_myprgenie if myprgenie_
    decrease_newswire_accesswire if accesswire_
    decrease_newswire_prnewswire if prnewswire_

    publicSuffix = (news_room.id && news_room.publish_on_website && !is_private) ? "" : "-preview"
    publicLink = "http://" + news_room.subdomain_name + publicSuffix + "." + Rails.application.secrets.host + "/releases/" + slug

    myprgenie_publish = myprgenie_published_at.strftime('%m/%d/%Y') if myprgenie_published_at
    accesswire_publish = accesswire_published_at.strftime('%m/%d/%Y') if accesswire_published_at
    prnewswire_publish = prnewswire_published_at.strftime('%m/%d/%Y') if prnewswire_published_at

    if (myprgenie_) || (accesswire_) || (prnewswire_)
      UserMailer.newswire_support(myprgenie_, accesswire_, prnewswire_, title, text, myprgenie_publish, accesswire_publish, prnewswire_publish, publicLink).deliver 
    end
  end

end
