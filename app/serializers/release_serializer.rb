class ReleaseSerializer < ActiveModel::Serializer
  embed :ids
  attributes :id, :user_id, :news_room_id, :news_room, :title, :text

  has_one :news_room
end