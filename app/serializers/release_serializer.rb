class ReleaseSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :news_room_id, 
    :news_room, :title, :text, 
    :is_private, :logo_url, :created_at,
    :concepts, :iptc_categories

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
end
