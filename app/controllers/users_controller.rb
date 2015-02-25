class UsersController < ApplicationController
  def get_current_user
    render json: current_user
  end

  def delete_user
    manageable_users = User.where(invited_by_id: current_user.id)
    manageable_users.find(params[:id]).destroy

    render json: manageable_users
  end

  def identities
    render json: current_user.identities
  end

  def disconnect_social
    @identity = current_user.identities.where(provider: params[:provider]).first
    @identity.destroy

    render json: current_user.identities
  end

  def manageable_users
    manageable_users = User.where(invited_by_id: current_user.id)
    render json: manageable_users
  end

  def follow
    maillist = Rails.application.secrets.mailgun[:maillist]
    @mailgun = Mailgun(api_key: Rails.application.secrets.mailgun[:api_key])
    if @mailgun
      mail_list = @mailgun.lists.find maillist
      @mailgun.lists.create maillist unless mail_list
      @mailgun.list_members.add maillist, params[:email]
    end
  end
  # @mailgun.list_members('test@mg.robin8.com').add('mykola.bokhonko@perfectial.com',{name: 'Vasa', vars: '{"newsroom": "1"}'})

end
