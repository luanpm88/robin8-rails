require 'jwt'
module AuthToken
  Algorithm = 'HS256'
  Secret = 'Robin888'
  Key = 'private_token'

  if Rails.env.production?
    Expired = 1.hours
  else
    Expired = 50.hours
  end

  def AuthToken.issue_token(private_token)
    payload = {Key => private_token}.to_json
    JWT.encode(payload, Secret, Algorithm)
  end

  def AuthToken.valid?(data)
    begin
      decoded_json_data = JWT.decode(data, Secret, true, {:algorithm => Algorithm})[0]    rescue ""
      decoded_data = JSON.parse(decoded_json_data)                                        rescue {}
      if decoded_data['time'].blank? || decoded_data[Key].blank?
        return [false, '格式错误' ]
      end
      if decoded_data['time'].to_i > (Time.now - Expired).to_i && decoded_data['time'].to_i <= Time.now.to_i
        return [true, decoded_data[Key]]
      else
        return [false, 'token已经过期' ]
      end
    rescue
      return [false, 'unknow']
    end
  end

  def AuthToken.test_issue_token
    kol = Kol.find 84
    payload = {Key => kol.get_private_token, :time => Time.now.to_i}.to_json
    token = JWT.encode(payload, Secret, Algorithm)
    puts token
    token
  end
end
