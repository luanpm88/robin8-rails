class ReleaseSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :news_room_id, 
    :news_room, :title, :text, :published_at, :formamtted_published_at,
    :is_private, :logo_url, :thumbnail, :created_at,
    :characters_count, :words_count, :sentences_count,
    :paragraphs_count, :adverbs_count, :adjectives_count,
    :nouns_count, :organizations_count, :places_count, :people_count,
    :concepts, :iptc_categories, :summaries, :hashtags, :plain_text,
    :subdomain_name, :news_room_public, :text_html, :slug, :permalink,
    :average_characters_count_per_word, :average_words_count_per_sentence,
    :myprgenie, :accesswire, :prnewswire, :newswire_published_at

  has_many :attachments
  has_one :news_room
  
  def concepts
    unless object.concepts.blank?
      JSON.parse(object.concepts)
    else
      []
    end
  end

  def formamtted_published_at
    object.published_at.strftime('%m\%d\%Y') unless object.published_at.nil? 
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
  
  def average_characters_count_per_word
    if !object.words_count.nil? && object.words_count != 0 
      object.characters_count / object.words_count
    else
      0
    end
  end
  
  def average_words_count_per_sentence
    if !object.sentences_count.nil? && object.sentences_count != 0
      object.words_count / object.sentences_count
    else
      0
    end
  end

  def subdomain_name
    news_room.subdomain_name
  end

  def news_room_public
    news_room.publish_on_website
  end

  def text_html
    text.try(:html_safe)
  end
end
