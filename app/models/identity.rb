class Identity < ActiveRecord::Base
  belongs_to :user
  belongs_to :kol  # should have used polymorphic association here
  has_many :kol_categories
  has_many :iptc_categories, :through => :kol_categories

  def self.find_for_oauth(auth)
    identity = find_by(provider: auth[:provider], uid: auth[:uid])
    identity || create_identity(auth)
  end

  def self.find_oauth_with_status(auth)
    identity = find_by(provider: auth[:provider], uid: auth[:uid])
    if identity
      return [identity, true]         # 已经存在
    else
      [self.create_identity(auth), false]
    end
  end

  def self.create_identity(auth)
    puts auth
    create(uid: auth[:uid], provider: auth[:provider], token: auth[:token], url: auth[:url],
           token_secret: auth[:token_secret], name: auth[:name], avatar_url: auth[:avatar_url], desc: auth[:desc])
  end

  def total_tasks
    14
  end

  def last30_posts
    22
  end

end



