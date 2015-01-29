class Identity < ActiveRecord::Base
  belongs_to :user

  def self.find_for_oauth(auth)
    identity = find_by(provider: auth[:provider], uid: auth[:uid])
    identity = create(uid: auth[:uid], provider: auth[:provider], token: auth[:token], name: auth[:name]) if identity.nil?
    identity
  end
end
