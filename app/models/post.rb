class Post < ActiveRecord::Base
  serialize :social_networks, Hash
  belongs_to :user
  validates :text, presence: true

  after_create :perform_worker

  scope :todays, -> { where("scheduled_date > ? AND scheduled_date < ?", DateTime.new.at_beginning_of_day, DateTime.now) }

  def perform_worker
    PostWorker.perform_async()
  end

end
