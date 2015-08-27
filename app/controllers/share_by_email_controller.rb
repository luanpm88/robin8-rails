class ShareByEmailController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def create
    @share_by_email = ShareByEmail.new(current_user, share_by_email_params)

    respond_to do |format|
      if @share_by_email.submit
        ContactMailer.delay.share_by_email(params[:share_by_email])
        format.json { render :show, status: :created,
          location: share_by_email_show_path(@share_by_mail) }
      else
        format.json { render json: @share_by_email.errors,
          status: :unprocessable_entity }
      end
    end
  end

  private

  def share_by_email_params
    params.require(:share_by_email).permit(:subject, :body, :sender, :reciever)
  end
end
