class ReleaseSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :news_room_id, 
    :news_room, :title, :text, 
    :is_private, :logo_url, :created_at,
    :concepts, :iptc_categories, :summaries, :plain_title, :plain_text,
    :hashtags

  has_many :attachments
  has_one :news_room
  
  def plain_title
    coder = HTMLEntities.new
    coder.decode ActionController::Base.helpers.strip_tags(object.title)
  end
  
  def plain_text
    coder = HTMLEntities.new
    coder.decode ActionController::Base.helpers.strip_tags(object.text)
  end
  
  def concepts
    unless object.concepts.blank?
      JSON.parse(object.concepts)
    else
      []
    end
  end
  
  def iptc_categories
    unless object.iptc_categories.blank?
      JSON.parse(object.iptc_categories)
    else
      []
    end
  end
  
  def summaries
    unless object.summaries.blank?
      JSON.parse(object.summaries)
    else
      []
    end
  end
  
  def hashtags
    unless object.hashtags.blank?
      JSON.parse(object.hashtags)
    else
      []
    end
  end
end
