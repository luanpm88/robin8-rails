module Brand::V2::APIHelpers

  EMAIL_REGEXP = /^([a-zA-Z0-9]+[_|\_|\.]+)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/

  def warden
    env['warden']
  end

  def current_user
    @current_user ||=
      if user = warden.authenticate(:scope => :user)
        user
      else
        error! 'Access Denied', 401
      end
  end

  def authenticate!
    error!('Access Denied', 401) unless current_user
  end

  def error_unprocessable! detail=nil
    error!({error: 'Unprocessable!', detail: detail}, 422)
  end

  def error_403! detail = nil
    error!({error: 'Access Denied', detail: detail}, 403)
  end
end
