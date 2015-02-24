class Release < ActiveRecord::Base
  belongs_to :user
  belongs_to :news_room

  validates :user_id, presence: true
  validates :title, presence: true

  has_many :attachments, as: :imageable, dependent: :destroy
  accepts_nested_attributes_for :attachments, allow_destroy: true

  scope :by_news_room, ->(id) {where(news_room_id: id)}
end
