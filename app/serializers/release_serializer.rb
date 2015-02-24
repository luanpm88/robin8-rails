class ReleaseSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :news_room_id, :news_room, :title, :text

  has_many :attachments
  has_one :news_room
end