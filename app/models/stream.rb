class Stream < ActiveRecord::Base
  belongs_to :user
  serialize :topics, Array
  serialize :sources, Array
  validates :sort_column, inclusion: { in: %w(published_at shares_count) }
end
