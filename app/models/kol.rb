class Kol < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, allow_unconfirmed_access_for: 1.days

  has_many :identities, :dependent => :destroy, autosave: true

  has_many :kol_categories
  has_many :iptc_categories, :through => :kol_categories

  has_many :campaign_invites
  has_many :campaigns, :through => :campaign_invites
  has_many :articles
  has_many :wechat_article_performances, as: :sender
  has_many :article_comments, as: :sender
  has_many :kol_profile_screens
  has_many :interested_campaigns

  validates :mobile_number, uniqueness: true

  GENDERS = {
    :NONE => 0,
    :MALE => 1,
    :FEMALE => 2
  }

  def self.check_mobile_number mobile_number
    return Kol.where("mobile_number" => mobile_number).present?
  end

  def active
    not confirmed_at.nil?
  end

  def stats

    cache_key = "social_stats_#{self.id}"
    res = Rails.cache.read cache_key

    if res.nil?

      stat = Hash.new
      stat[:total] = 0
      stat[:total_beat] = 0
      stat[:total_progress] = 0
      stat[:channels] = 0
      stat[:completeness] = 0
      stat[:fans] = 0
      stat[:content] = 0
      stat[:engagement] = 0

      accounts = 0
      token, uid, token_secret = ""

      self.identities.each do |identity|
        case identity.provider
          when "weibo"
            uid = identity.uid
            token = identity.token
            token_secret = identity.token_secret
            accounts += 1
          when "wechat"
            accounts += 1
          when "linkedin"
            accounts += 1
        end
      end

      if !self.wechat_public_id.nil? && !self.wechat_public_name.nil?
        accounts += 1
      end

      case accounts
        when 0
          stat[:channels] = 0
        when 1
          stat[:channels] = 10
        when 2
          stat[:channels] = 15
        when 3
          stat[:channels] = 20
        when 4
          stat[:channels] = 25
        else
          stat[:channels] = 30
      end

      stat[:total] += stat[:channels]

      if not uid.blank?
        begin
          weibo_show_key = "weibo_show_#{uid}"
          response = Rails.cache.read weibo_show_key
          if response.nil?
            response = HTTParty.get("https://api.weibo.com/2/users/show.json",
                                    headers: { 'Content-Type' => 'application/json'},
                                    query: {access_token: token, uid: uid})
            Rails.cache.write weibo_show_key, response.to_h, :expires_in => 24.hours
          end

          #valid
          stat[:completeness] = 20
          #completeness
          #has description
          if response['description'] != ''
            stat[:completeness] += 10
          end
          #has avatar
          if response['profile_image_url'] != ''
            stat[:completeness] += 10
          end
          stat[:total] += stat[:completeness]
          #fans
          fans =  response['followers_count'].to_i
          friend = response['friends_count'].to_i
          if fans > 1000 && friend > 100
            stat[:fans] = 10
            stat[:total] +=  10
          end
          #content & engagement
          weibo_timeline_key = "weibo_timeline_#{uid}"
          response = Rails.cache.read weibo_timeline_key
          if response.nil?
            response = HTTParty.get("https://api.weibo.com/2/statuses/user_timeline.json",
                                                headers: { 'Content-Type' => 'application/json'},
                                                query: {access_token: token, uid: uid})
            Rails.cache.write weibo_timeline_key, response.to_h, :expires_in => 24.hours
          end
          current = Time.now
          content = Hash.new
          unless response['statuses'].blank?
            response['statuses'].each do |status|
              date = Date.parse status['created_at']
              if (current.month - date.month) <= 5
                if !content[(current.month - date.month)].is_a?(Hash)
                  content[(current.month - date.month)] = Hash.new
                  content[(current.month - date.month)][:post] = 0
                  content[(current.month - date.month)][:repost] = 0
                end
                content[(current.month - date.month)][:post] +=  + 1
                content[(current.month - date.month)][:repost] +=  status['reposts_count'] + status['comments_count']
              end
            end
          end
          post = true
          repost = true
          if content.length == 6
            content.each do |content|
              if content[:post] == 0
                post = false
              end

              if content[:repost] == 0
                repost = false
              end
            end
          else
            post = false
            repost = false
          end
          if post
            stat[:content] = 10
            stat[:total] += 10
          end
          if repost
            stat[:engagement] = 10
            stat[:total] += 10
          end
        rescue => ex
          puts ex.inspect
          puts ex.backtrace
        end
      end

      # progress and beat calculation
      t = stat[:total]
      stat[:total_beat] = ((Kol.where("stats_total < ?", t).count.to_f / Kol.count) * 100).to_i

      if self.stats_total_changed.nil? or (self.stats_total_changed + 1.month < Time.now)
        self.stats_total = t
        self.stats_total_changed = Time.now
        self.save
        stat[:total_progress] = 0
      else
        stat[:total_progress] = t - self.stats_total
      end

      Rails.cache.write cache_key, stat, :expires_in => 10.minutes
      return stat
    else
      return res
    end
  end

  def categories
    iptc_categories.reload.map do |c|
      { :id => c.id, :label => c.label }
    end
  end

  def screens
    kol_profile_screens.reload.map do |c|
      { :id => c.id, :url => c.url, :thumbnail => c.thumbnail, :social_name => c.social_name }
    end
  end

  def serializable_hash(options={})
    res = super(options)
    sign_in_info = {
      "sign_in_count" => self.sign_in_count,
      "last_sign_in_at" => self.last_sign_in_at
    }
    res["sign_in_info"] = sign_in_info
    res
  end

  def self.find_for_oauth(auth)
    identity = Identity.find_by(provider: auth[:provider], uid: auth[:uid])
    if identity
      return identity.kol
    else
      return nil
    end
  end

end
