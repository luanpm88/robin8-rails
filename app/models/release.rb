class Release < ActiveRecord::Base
  belongs_to :user
  belongs_to :news_room

  scope :by_news_room, ->(id) {where(news_room_id: id)}
end
