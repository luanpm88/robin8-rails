module Users
  class SessionsController < Devise::SessionsController
    respond_to :html, :json

    # only hide flash info
    def destroy
      signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
      yield if block_given?
      respond_to_on_destroy
    end

  end
end
