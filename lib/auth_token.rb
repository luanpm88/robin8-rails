require 'jwt'
module AuthToken
  Algorithm = 'HS256'
  Secret = 'Robin888'
  Key = 'private_token'

  if Rails.env.production?
    Expired = 1.hours
  else
    Expired = 5000.hours
  end

  def AuthToken.issue_token(private_token)
    payload = {Key => private_token}
    JWT.encode(payload, Secret, Algorithm)
  end

  def AuthToken.valid?(data)
    begin
      decoded_data = JWT.decode(data, Secret, true, {:algorithm => Algorithm})[0]    rescue ""
      if decoded_data['time'].blank? || decoded_data[Key].blank?
        Rails.logger.info "-----decoded data: #{decoded_data} --- 格式错误"
        return [false, '格式错误' ]
      end
      if decoded_data['time'].to_i > (Time.now - Expired).to_i && (decoded_data['time'].to_i <= (Time.now + 10.minutes).to_i)
        return [true, decoded_data[Key]]
      else
        Rails.logger.info "-----decoded data: #{decoded_data} --#{Time.now.to_i}--- token已经过期"
        return [false, 'token已经过期' ]
      end
    rescue
      Rails.logger.info "-----  data: #{data} --- unknow"
      return [false, 'unknow']
    end
  end

  def AuthToken.test_issue_token(mobile_number = '13817164642')
    kol = Kol.find_by :mobile_number => mobile_number
    payload = {Key => kol.get_private_token, :time => Time.now.to_i}
    token = JWT.encode(payload, Secret, Algorithm)
    puts token
    token
  end
end
