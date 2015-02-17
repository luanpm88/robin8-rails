class Stream < ActiveRecord::Base
  belongs_to :user
  serialize :topics, Array
  serialize :blogs, Array
  validates :sort_column, inclusion: { in: %w(published_at shares_count) }

  def query_params
    {
      'blog_ids[]' => blogs.map{|blog| blog[:id]},
      'topics[]' => topics.map{|topic| topic[:id]},
      sort_column: sort_column,
      sort_direction: 'desc'
    }
  end
end
