class Kol < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable, allow_unconfirmed_access_for: 1.days

  has_many :identities, :dependent => :destroy

  has_many :kol_categories
  has_many :iptc_categories, :through => :kol_categories

  has_many :campaign_invites
  has_many :campaigns, :through => :campaign_invites
  has_many :articles
  has_many :wechat_article_performances, as: :sender
  has_many :article_comments, as: :sender
  has_many :kol_profile_screens

  GENDERS = {
    :NONE => 0,
    :MALE => 1,
    :FEMALE => 2
  }

  include Models::Identities
  extend Models::Oauth

  class EmailValidator < ActiveModel::Validator
    def validate(record)
      if record.new_record? and User.exists?(:email=>record.email)
        record.errors[:email] << "has already been taken"
      end
    end
  end

  validates_with EmailValidator

  def active
    not confirmed_at.nil?
  end

  def stats
    stat = Hash.new
    stat[:total] = 0
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

    if self.wechat_public_id != '' && self.wechat_public_name != ''
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


    begin
      response = HTTParty.get("https://api.weibo.com/2/users/show.json",
                               headers: { 'Content-Type' => 'application/json'},
                               query: {access_token: token, uid: uid})

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
      response =  response = HTTParty.get("https://api.weibo.com/2/statuses/user_timeline.json",
                                          headers: { 'Content-Type' => 'application/json'},
                                          query: {access_token: token, uid: uid})
      current = Time.now
      content = Hash.new
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
    end

    return stat
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

end
