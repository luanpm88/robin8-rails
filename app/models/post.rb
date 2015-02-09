class Post < ActiveRecord::Base
  belongs_to :user
  validates :text, presence: true

  after_create :perform_worker

  def perform_worker
    PostWorker.perform_async()
  end

end
