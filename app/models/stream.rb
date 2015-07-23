class Stream < ActiveRecord::Base
  belongs_to :user
  has_one :alert
  
  serialize :topics, Array
  serialize :blogs, Array
  serialize :keywords, Array
  validates :sort_column, inclusion: { in: %w(published_at shares_count) }
  validates :position, numericality: { greater_than_or_equal_to: 0 },
                       uniqueness: { scope: :user_id },
                       allow_nil: true
  validate :can_be_created, on: :create

  after_create :set_position, :decrease_feature_number
  after_destroy :increase_feature_number


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
    q_params = {
      'blog_ids[]' => blogs.map{|blog| blog[:id]},
      'topics[]' => topics.map{|topic| topic[:id]},
      'keywords[]' => keywords.map{|keyword| keyword[:id]},
      sort_column: sort_column,
      sort_direction: 'desc'
    }

    if (sort_column == 'shares_count' && !published_at.blank?)
      q_params[:published_at] = published_at
    end

    q_params
  end

  def stream_title
    title_arr = []
    title_arr << (sort_column == "shares_count" ? "Top" : "Latest")
    title_arr << "articles"

    topic_titles = (topics + keywords).map do |topic|
      topic[:text]
    end.uniq {|t| t.strip.downcase}

    topic_titles.insert(3, "more") if topic_titles.size > 3

    if topic_titles.size > 0
      title_arr << "about"
      title_arr << topic_titles.take(4).to_sentence
    end

    blog_names = blogs.map do |b|
      b[:text]
    end

    if blog_names.size > 0
      title_arr << "from"
      title_arr << blog_names.to_sentence
    end

    title_arr.join(' ')
  end

  private

    def needed_user
      user.is_primary? ? user : user.invited_by
    end

    def invited_users_list
      current_users=User.where(invited_by_id: needed_user.id)
      invited_id=""
      current_users.all.each do |current_user|
        invited_id << current_user.id.to_s << ", "
      end
      return invited_id << needed_user.id.to_s
    end

    def can_be_created
      errors.add(:user, "You've reached the max numbers of streams.") if needed_user && !needed_user.can_create_stream
    end

    def decrease_feature_number
      users_id = invited_users_list
      af = user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").media_monitoring.available.joins(:product).where(products: {is_package: false}).first
      uf = af.nil? ? user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").media_monitoring.available.first : af
      return false if uf.blank?
      uf.available_count -= 1
      uf.save
    end

    def increase_feature_number
      users_id = invited_users_list
      af = user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").media_monitoring.available.joins(:product).where(products: {is_package: false}).first
      uf = af.nil? ? user_features.unscope(where: :user_id).where("user_features.user_id IN (#{users_id})").media_monitoring.used.first : af
      return false if uf.blank?
      uf.available_count += 1
      uf.save
    end

end
