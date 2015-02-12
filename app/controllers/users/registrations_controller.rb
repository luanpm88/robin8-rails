module Users
  class RegistrationsController < Devise::RegistrationsController
    respond_to :html, :json

    protected

    def update_resource(resource, params)
      if params[:password]=="" && params[:password_confirmation]=="" 
        params.delete(:current_password)
        resource.update_without_password(params)
      else
        resource.update_with_password(params)
      end
    end

  end
end