class PasswordHandle
  Algorithm = 'HS256'
  Secret = 'Robin888'
  Key = 'password'


  def self.encode_pwd(password)
    payload = {Key => password}
    JWT.encode(payload, Secret, Algorithm)
  end

  def self.decode_pwd(data)
    JWT.decode(data, Secret, true, {:algorithm => Algorithm})[0][Key]
  end

end
