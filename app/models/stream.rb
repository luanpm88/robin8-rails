class Stream < ActiveRecord::Base
  belongs_to :user
  serialize :topics, Array
  serialize :blogs, Array
  serialize :keywords, Array
  validates :sort_column, inclusion: { in: %w(published_at shares_count) }
  validates :position, numericality: { greater_than_or_equal_to: 0 },
                       uniqueness: { scope: :user_id },
                       allow_nil: true
  validate :can_be_created, on: :create

  after_create :set_position, :decrease_feature_number
  after_destroy :increase_feature_numner


  def set_position
    last_stream = Stream.order('position DESC').first
    self.position = (last_stream.nil? || last_stream.position.nil?) ? 1 : last_stream.position + 1
    self.save!
  end

  def query_params
    {
      'blog_ids[]' => blogs.map{|blog| blog[:id]},
      'topics[]' => topics.map{|topic| topic[:id]},
      'keywords[]' => keywords.map{|keyword| keyword[:id]},
      sort_column: sort_column,
      sort_direction: 'desc',
      published_at: sort_column == 'shares_count' ? published_at : nil
    }
  end

  private

    def can_be_created
      errors.add(:user, "you've reached the max numbers of streams.") if user && !user.can_create_stream
    end

    def decrease_feature_number
      uf = user.user_features.media_monitoring.available.first
      return false if uf.blank?
      uf.available_count -= 1
      uf.save
    end

    def increase_feature_numner
      uf = user.user_features.media_monitoring.not_available.first
      return false if uf.blank?
      uf.available_count += 1
      uf.save
    end

end
