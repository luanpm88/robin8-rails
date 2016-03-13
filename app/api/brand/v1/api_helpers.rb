module Brand::V1::APIHelpers

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

  def error_unprocessable! detail=nil
    error!({error: 'Unprocessable!', detail: detail}, 422)
  end
end
