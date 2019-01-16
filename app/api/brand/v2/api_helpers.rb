module Brand::V2::APIHelpers

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

  def is_super_user?
    warden.authenticate(:scope => :admin_user).present?
  end

  def can?(*args)
    current_ability.can?(*args)
  end

  def authorize!(*args)
    current_ability.authorize!(*args)
  end

  def current_ability
    @current_ability ||= ::Ability.new(current_user)
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
