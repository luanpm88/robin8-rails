ActiveAdmin.register EmailApprove do

  actions :all, :except => [:new, :destroy]

  permit_params :email

  member_action :approve, method: :put do
    #redirect_to robin8_api_authors_update_path, :method => :put, id: params[:id] and return


    email = EmailApprove.find(params[:id])
    @client = AylienPressrApi::Client.new
    parameters = Hash.new(0)
    parameters[:id] = email.author_id.to_s
    parameters[:email] = email.email

    @client.author_update(nil,parameters)
    EmailApprove.delete(params[:id])
    redirect_to admin_email_approves_path, notice: "Approved!"
  end

  member_action :decline, method: :delete do
    EmailApprove.delete(params[:id])
    redirect_to admin_email_approves_path, notice: "Declined!"
  end

  index do
    id_column
    column "User ID", :user_id
    column "Author ID", :author_id
    column :first_name
    column :last_name
    column :outlet
    column :email
    actions defaults: false do |email|
      link_to 'Approve', approve_admin_email_approfe_path(email), :method => :put

    end

    actions defaults: false do |email|

      link_to 'Decline', decline_admin_email_approfe_path(email.id), :method => :delete
    end

    actions
  end

end



