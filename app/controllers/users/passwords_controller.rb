module Users
  class PasswordsController < Devise::PasswordsController
    respond_to :html, :json

    def create
      super do
        unless self.resource.persisted?
          self.resource = Kol.send_reset_password_instructions resource_params
          resource_name = :kol
        end
      end
    end

  end
end
