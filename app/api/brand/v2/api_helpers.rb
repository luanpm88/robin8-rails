module Brand::V2::APIHelpers
  EMAIL_REGEXP = /^([a-zA-Z0-9]+[_|\_|\.]+)*[a-zA-Z0-9]+@([a-zA-Z0-9]+[_|\_|\.]?)*[a-zA-Z0-9]+\.[a-zA-Z]{2,3}$/
  #MOBILE_NUMBER_REGEXP = /^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\d{8,10}$/
  MOBILE_NUMBER_REGEXP = /^(09|03|07|08|05|84[^0]|\+84[^0])\d{7,9}$/

  def current_user
    result , private_token = AuthToken.valid?(headers["Authorization"])
    if result
      kol = Kol.app_auth(private_token)
      error!('Access Denied', 401) unless kol
      @current_user = kol.user
    end
  end

  def set_locale
    locale = params[:locale]  if  params[:locale].present?
    I18n.locale = locale || I18n.default_locale
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
