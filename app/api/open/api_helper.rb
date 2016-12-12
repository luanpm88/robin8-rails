module Open
  module ApiHelper
    def authenticate!
      raise Open::UnauthorizationError.new unless current_user
    end

    def request_limit!
      reqcount_key = "robin8:open:access_token:#{@token}:reqcount"
      $redis.setex(reqcount_key, 1, 0) unless $redis.exists(reqcount_key)
      # raise Open::LimitationError.new if $redis.incr(reqcount_key) > 5
    end

    def current_user
      return @current_user if @current_user

      @token = params[:token] || request.headers["Authorization"]
      user_id = $redis.hget("robin8:open:access_tokens", @token)
      user_id = 829 if Rails.env.development? && current_user.blank?
      @current_user = User.where(id: user_id).take if user_id
    end

    def logger
      OpenAPI.logger
    end

    #return kb
    def img_size(remote_url)
      filename = "/tmp/#{Time.now.to_i}.png"
      open(filename, 'wb') do |file|
        file << open(remote_url).read
      end
      File.size?(filename) / 1000
    end
  end
end
