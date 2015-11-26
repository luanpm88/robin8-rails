module Users
  class PasswordsController < Devise::PasswordsController
    respond_to :html, :json

    def create
      self.resource = resource_class.send_reset_password_instructions(resource_params)

      unless self.resource.persisted?
        self.resource = Kol.send_reset_password_instructions resource_params
        resource_name = :kol
      end

      yield resource if block_given?

      if successfully_sent?(resource)
        respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
      else
        respond_with(resource)
      end
    end
  end
end
