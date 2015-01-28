module Users
  class PasswordsController < Devise::PasswordsController
    respond_to :html, :json

  end
end
