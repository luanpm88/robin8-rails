class Post < ActiveRecord::Base
  # serialize :social_networks, Hash
  serialize :twitter_ids, Array
  serialize :facebook_ids, Array
  serialize :linkedin_ids, Array

  belongs_to :user
  validates :text, presence: true
  validates :scheduled_date, presence: true

  after_create :perform_worker

  scope :todays, -> { where("scheduled_date > ? AND scheduled_date < ?", DateTime.now.utc, DateTime.now.utc.end_of_day) }
  scope :tomorrows, -> { where("scheduled_date > ? AND scheduled_date < ?", DateTime.now.utc.beginning_of_day + 1, DateTime.now.utc.end_of_day + 1) }
  scope :others, -> { where("scheduled_date > ?", DateTime.now.utc.beginning_of_day + 2) }

  def social_networks_raw
    self.social_networks
  end

  def social_networks_raw=(values)
    self.social_networks = []
    self.social_networks=values.split(",")
  end

  def perform_worker
    PostWorker.perform_at(scheduled_date, id)
  end

end
