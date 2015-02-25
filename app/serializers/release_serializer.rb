class ReleaseSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :news_room_id, :news_room, :title, :text, :is_private, :logo_url, :created_at

  has_many :attachments
  has_one :news_room

end