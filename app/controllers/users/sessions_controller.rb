module Users
  class SessionsController < Devise::SessionsController
    respond_to :html, :json


    # POST /resource/sign_in
    def create
      if not self.resource = warden.authenticate(auth_options)
        render :template => 'users/session_create_failed.js.erb' and return
      end
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      unless cookies[:remember_signed_in]
        cookies.permanent[:remember_signed_in] = SecureRandom.hex
        UserSignInRecord.create(sign_in_token: cookies.permanent[:remember_signed_in], user_id: resource.id)
      end
      yield resource if block_given?
      render :template => 'users/session_create_success.js.erb'
      # respond_with resource, location: after_sign_in_path_for(resource)
    end

    # only hide flash info
    def destroy
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      yield if block_given?
      respond_to_on_destroy
    end

  end
end
