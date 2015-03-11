class Stream < ActiveRecord::Base
  belongs_to :user
  serialize :topics, Array
  serialize :blogs, Array
  validates :sort_column, inclusion: { in: %w(published_at shares_count) }
  validates :position, numericality: { greater_than_or_equal_to: 0 },
                       uniqueness: { scope: :user_id },
                       allow_nil: true

  after_create :set_position

  def set_position
    last_stream = Stream.order('position DESC').first
    self.position = (last_stream.nil? || last_stream.position.nil?) ? 1 : last_stream.position + 1
    self.save!
  end

  def query_params
    {
      'blog_ids[]' => blogs.map{|blog| blog[:id]},
      'topics[]' => topics.map{|topic| topic[:id]},
      sort_column: sort_column,
      sort_direction: 'desc',
      published_at: sort_column == 'shares_count' ? published_at : nil
    }
  end
end
