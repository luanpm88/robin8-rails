class TrackUrl < ActiveRecord::Base
  validates_uniqueness_of :origin_url, :message => "原始链接不能重复"
  after_create :set_track_short_url

  scope :enabled, -> { where(enabled: true) }

  def set_track_short_url
    self.update(:short_url => SecureRandom.hex)
  end

  def short_url_text
    File.join(Rails.application.secrets[:domain], "track_urls/#{self.short_url}")
  end
end
