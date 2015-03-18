class Release < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :user
  belongs_to :news_room, counter_cache: true
  has_many :pitches

  validates :user_id, presence: true
  validates :title, presence: true

  has_many :attachments, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true

  scope :by_news_room, ->(id) {where(news_room_id: id)}
  scope :published, -> { where(is_private: false) }
  
  before_save :pos_tagger, :entities_counter
  
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
  
  private
  
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
end
