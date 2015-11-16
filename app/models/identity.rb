class Identity < ActiveRecord::Base
  belongs_to :user
  belongs_to :kol  # should have used polymorphic association here

  def self.find_for_oauth(auth)
    identity = find_by(provider: auth[:provider], uid: auth[:uid])
    identity = create(email: auth[:email], uid: auth[:uid], provider: auth[:provider], token: auth[:token], url: auth[:url],
                      token_secret: auth[:token_secret], name: auth[:name]) if identity.nil?
    identity
  end
end
