class ReleaseSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :news_room_id, 
    :news_room, :title, :text, 
    :is_private, :logo_url, :created_at,
    :characters_count, :words_count, :sentences_count,
    :paragraphs_count, :adverbs_count, :adjectives_count,
    :nouns_count, :organizations_count, :places_count, :people_count,
    :concepts, :iptc_categories, :summaries, :hashtags, :plain_text,
    :subdomain_name, :news_room_public

  has_many :attachments
  has_one :news_room
  
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

  def subdomain_name
    news_room.subdomain_name
  end

  def news_room_public
    news_room.publish_on_website
  end
end
