require 'jwt'
module AuthToken
  Algorithm = 'HS256'
  Secret = 'Robin888'
  Key = 'private_token'

  if Rails.env.production?
    Expired = 24.hours
  else
    Expired = 5000.hours
  end

  def AuthToken.issue_token(private_token)
    payload = {Key => private_token}
    JWT.encode(payload, Secret, Algorithm)
  end

  #校验用户
  def AuthToken.valid?(data)
    begin
      decoded_data = JWT.decode(data, Secret, true, {:algorithm => Algorithm})[0]    rescue ""
      if decoded_data['time'].blank? || decoded_data[Key].blank?
        Rails.logger.info "-----decoded data: #{decoded_data} --- 格式错误"
        return [false, '格式错误' ]
      end
      if AuthToken.valid_time?(decoded_data)
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


  def AuthToken.can_get_code?(data)
    begin
      decoded_data = JWT.decode(data, Secret, true, {:algorithm => Algorithm})[0]    rescue ""
      if decoded_data['time'].blank? || decoded_data['get_code'].blank?  || !AuthToken.valid_time?(decoded_data)
        return false
      else
        return true
      end
    end
  end


  def AuthToken.valid_time?(decoded_data)
    return decoded_data['time'].to_i > (Time.now - Expired).to_i && (decoded_data['time'].to_i <= (Time.now + 24.hours).to_i)
  end

  def AuthToken.test_issue_token(mobile_number = '13817164642')
    kol = Kol.find_by :mobile_number => mobile_number
    payload = {Key => kol.get_private_token, :get_code => 'get_code', :time => Time.now.to_i}
    token = JWT.encode(payload, Secret, Algorithm)
    puts token
    token
  end
end
