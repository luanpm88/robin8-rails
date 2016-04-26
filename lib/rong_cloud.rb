require 'rest-client'
class RongCloud
  Server = 'https://api.cn.ronghub.com'
  AppKey = Rails.application.secrets[:rong_cloud][:app_key]
  AppSecret = Rails.application.secrets[:rong_cloud][:app_secret]

  def self.generate_headers
    headers = {}
    headers['AppKey'] = AppKey
    headers['Nonce'] = SecureRandom.hex
    headers['Timestamp'] = Time.now.to_i
    headers['Signature'] =  Digest::SHA1.hexdigest("#{AppSecret}#{headers['Nonce']}#{headers['Timestamp']}")
    return headers
  end

  def self.get_token(kol)
    headers = generate_headers
    server = "#{Server}/user/getToken.json"
    puts server
    res_json = RestClient.post server, {:userId => kol.id, :name => kol.name, :portraitUri => kol.avatar_url}, headers     rescue nil
    return nil if res_json.blank?
    res  = JSON.parse res_json
    res['token']
  end
end
