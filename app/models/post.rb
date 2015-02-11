class Post < ActiveRecord::Base
  serialize :social_networks, Hash
  belongs_to :user
  validates :text, presence: true
  validates :scheduled_date, presence: true

  after_create :perform_worker

  scope :todays, -> { where("scheduled_date > ? AND scheduled_date < ?", DateTime.now.beginning_of_day, DateTime.now.end_of_day) }

  def perform_worker
    PostWorker.perform_async()
  end

end
