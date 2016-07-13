class HotItem < ActiveRecord::Base
  include Redis::Objects
  counter :redis_read_count

  def read_url
    "#{Rails.application.secrets.domain}/read_hot_item?id=#{self.id}"
  end
end
