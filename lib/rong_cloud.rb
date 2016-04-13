require 'rest-client'
class RongCloud
  Server = 'https://api.cn.ronghub.com'
  AppKey = Rails.application.secrets[:rong_cloud][:app_key]
  AppSecret = Rails.application.secrets[:rong_cloud][:app_secret]

  def self.generate_headers
    headers = {}
    headers[:nonce] = SecureRandom.hex
    headers[:time_stamp] = Time.now.to_i
    headers[:signature] =  Digest::SHA1.hexdigest("#{AppSecret}#{headers[:nonce]}#{headers[:time_stamp]}")
    return headers
  end

  def self.get_token(kol)
    headers = generate_headers
    server = "#{Server}/user/getToken.json"
    res = RestClient.post server, {:userId => kol.id, :name => kol.name, :portraitUri => kol.avatar_url}, headers
    puts res
  end
end
