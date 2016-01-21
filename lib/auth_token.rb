require 'jwt'
module AuthToken
  Algorithm = 'HS256'
  Secret = 'Robin888'
  Key = 'private_token'
  if Rails.env.production?
    Expired = 1.hours
  else
    Expired = 24.hours
  end

  def AuthToken.issue_token(private_token)
    payload = {Key => private_token}
    JWT.encode(payload, Secret, Algorithm)
  end

  def AuthToken.valid?(data)
    begin
      decoded_data = JWT.decode(data, Secret, true, {:algorithm => Algorithm})[0]
      send_time = decoded_data['time']
      if send_time.to_i > (Time.now - Expired).to_i && send_time.to_i <= Time.now.to_i
        return [true, decoded_data[key]]
      else
        return [false, 'token is expired' ]
      end
    rescue
      false
    end
  end

  def AuthToken.test_issue_token(private_token)
    payload = {Key => private_token, :time => Time.now.to_i}
    token = JWT.encode(payload, Secret, Algorithm)
    puts token
    token
  end
end
