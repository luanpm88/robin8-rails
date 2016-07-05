module Users
  class SessionsController < Devise::SessionsController
    respond_to :html, :json

    # POST /resource/sign_in
    def create
      auth_params = params.require("user").permit(:login, :password)

      unless kol = Kol.authenticate_password(auth_params)
        render :template => 'users/session_create_failed.js.erb' and return
      end

      set_flash_message(:notice, :signed_in) if is_flashing_format?

      self.resource = kol.find_or_create_brand_user
      sign_in(resource_name, self.resource)
      set_union_access_token

      render :template => 'users/session_create_success.js.erb'
    end

    # only hide flash info
    def destroy
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      yield if block_given?
      respond_to_on_destroy
    end

    def after_sign_out_path_for(resource_or_scope)
      brands_moments_path
    end

  end
end
