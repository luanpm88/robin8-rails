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


  def topics_raw
    self.topics#.join(",") unless self.topics.nil?
  end

  def topics_raw=(values)
    self.topics = []
    self.topics=values.split(",")
  end

  def blogs_raw
    self.blogs
  end

  def blogs_raw=(values)
    self.blogs = []
    self.blogs=values.split(",")
  end

  def keywords_raw
    self.keywords
  end

  def keywords_raw=(values)
    self.keywords = []
    self.keywords=values.split(",")
  end

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

    def needed_user
      user.is_primary? ? user : user.invited_by
    end

    def can_be_created
      errors.add(:user, "You've reached the max numbers of streams.") if needed_user && !needed_user.can_create_stream
    end

    def decrease_feature_number
      af = needed_user.user_features.media_monitoring.available.joins(:product).where(products: {is_package: false}).first
      uf = af.nil? ? needed_user.user_features.media_monitoring.available.first : af
      return false if uf.blank?
      uf.available_count -= 1
      uf.save
    end

    def increase_feature_numner
      af = needed_user.user_features.media_monitoring.available.joins(:product).where(products: {is_package: false}).first
      uf = af.nil? ? needed_user.user_features.media_monitoring.available.first : af
      return false if uf.blank?
      uf.available_count += 1
      uf.save
    end

end
