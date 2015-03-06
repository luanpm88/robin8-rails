module Users
  class ConfirmationsController < Devise::ConfirmationsController
    def show
      self.resource = resource_class.confirm_by_token(params[:confirmation_token])
      yield resource if block_given?

      if resource.errors.empty?
        flash[:success_confirmation] = "Your email address has been successfully confirmed."
        #redirect_to root_path
        redirect_to "/signin/"
      else
        respond_with_navigational(resource.errors, status: :unprocessable_entity){ render :new }
      end
    end
  end
end