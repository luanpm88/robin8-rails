class Announcement < ActiveRecord::Base
	include Redis::Objects

	counter :redis_clicks_count

  mount_uploader :logo, ImageUploader
  mount_uploader :banner, ImageUploader

  DetailTypes = %i(invite_friend check_in open_puts_wallet web only_show)

  validates_presence_of :title, :url, :banner

  has_many :announcement_shows

  #detail_type %w(invite_friend check_in complete_info url)
  scope :active, -> {where(:display => true)}
  scope :order_by_position, ->{order("position asc")}
  
  def banner_url
		self['banner']
	end
end
