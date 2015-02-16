class Stream < ActiveRecord::Base
  belongs_to :user
  serialize :topic_ids, Array
  serialize :blog_ids, Array
  validates :sort_column, inclusion: { in: %w(published_at shares_count) }
end
