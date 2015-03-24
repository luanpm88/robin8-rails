class Users::InvitationsController < Devise::InvitationsController
  respond_to :html, :json

  def create
    @user = User.find_by(email: invite_params[:email])
    if @user
      message = @user.invitation_accepted_at ? "active" : "resent"
    else
      message = "sent"
    end
    self.resource = invite_resource
    resource_invited = resource.errors.empty?
    yield resource if block_given?
    if resource_invited
      if is_flashing_format? && self.resource.invitation_sent_at
        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      respond_with message, :location => after_invite_path_for(current_inviter)
    else
      respond_with_navigational(resource) { render :new }
    end
  end

end
